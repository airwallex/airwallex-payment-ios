#!/usr/bin/env python3
"""Post-process DocC markdown for publishing on the md-doc branch.

Pipeline (run in order):
  1. Sanitize paths   — rename files with characters invalid for GitHub Actions artifacts
  2. Enrich content   — merge abstracts, deprecation notes, and topic sections from JSON
  3. Rewrite links    — replace DocC /documentation/ URLs with GitHub blob URLs on md-doc
"""

from __future__ import annotations

import json
import os
import re
import sys
from pathlib import Path
from urllib.parse import quote

# Characters forbidden in GitHub Actions artifact paths (NTFS compatibility).
# https://github.com/actions/toolkit/blob/main/packages/artifact/docs/faq.md
INVALID_PATH_CHARS = '":<>|*?\r\n'

# DocC-style link targets produced by DocC or enrichment.
DOC_LINK_RE = re.compile(
    r"\]\("
    r"(?P<target>"
    r"/documentation/[^)]+"
    r"|doc://[^)]+/documentation/[^)]+"
    r")"
    r"\)"
)

# Shared state for link resolution during enrichment and rewrite.
_path_index: dict[str, str] = {}
_blob_base: str = ""


# ---------------------------------------------------------------------------
# Step 1: Sanitize paths
# ---------------------------------------------------------------------------


def sanitize_component(name: str) -> str:
    sanitized = name
    for char in INVALID_PATH_CHARS:
        sanitized = sanitized.replace(char, "-")
    return sanitized


def sanitize_relative_path(rel_path: str) -> str:
    return "/".join(sanitize_component(part) for part in rel_path.split("/"))


def unique_sanitized_path(rel_path: str, used: set[str]) -> str:
    candidate = sanitize_relative_path(rel_path)
    if candidate not in used:
        return candidate

    path = Path(candidate)
    parent = path.parent.as_posix()
    stem = path.stem
    suffix = path.suffix
    index = 2
    while True:
        name = f"{stem}-{index}{suffix}"
        candidate = f"{parent}/{name}" if parent != "." else name
        if candidate not in used:
            return candidate
        index += 1


def collect_file_renames(root: Path) -> dict[Path, Path]:
    renames: dict[Path, Path] = {}
    used_targets: set[str] = set()

    for path in sorted(root.rglob("*"), key=lambda item: item.as_posix()):
        if not path.is_file():
            continue

        rel = path.relative_to(root).as_posix()
        if rel in used_targets:
            continue

        if sanitize_relative_path(rel) == rel:
            used_targets.add(rel)
            continue

        new_rel = unique_sanitized_path(rel, used_targets)
        used_targets.add(new_rel)
        renames[path] = root / new_rel

    return renames


def apply_renames(renames: dict[Path, Path]) -> None:
    for old, new in sorted(renames.items(), key=lambda item: len(item[0].parts), reverse=True):
        new.parent.mkdir(parents=True, exist_ok=True)
        old.rename(new)


def update_text_references(root: Path, renames: dict[Path, Path]) -> None:
    replacements: list[tuple[str, str]] = []
    for old, new in renames.items():
        old_rel = old.relative_to(root).as_posix()
        new_rel = new.relative_to(root).as_posix()
        replacements.append((old_rel, new_rel))
        replacements.append((Path(old_rel).name, Path(new_rel).name))

    for old, new in sorted(set(replacements), key=lambda item: len(item[0]), reverse=True):
        for path in root.rglob("*"):
            if not path.is_file():
                continue
            if path.suffix not in {".md", ".json"} and path.name != "package-list":
                continue
            text = path.read_text(encoding="utf-8")
            updated = text.replace(old, new)
            if updated != text:
                path.write_text(updated, encoding="utf-8")


def sanitize_markdown_paths(root: Path) -> int:
    """Rename files whose paths contain characters rejected by upload-artifact."""
    renames = collect_file_renames(root)
    if not renames:
        return 0

    apply_renames(renames)
    update_text_references(root, renames)
    return len(renames)


# ---------------------------------------------------------------------------
# Step 3: Rewrite links (helpers also used during enrichment)
# ---------------------------------------------------------------------------


def github_blob_base() -> str:
    repo = os.environ.get("GITHUB_REPOSITORY", "airwallex/airwallex-payment-ios")
    branch = os.environ.get("MD_DOCS_BRANCH", "md-doc")
    prefix = os.environ.get("MD_DOCS_PREFIX", "md-docs").strip("/")
    return f"https://github.com/{repo}/blob/{branch}/{prefix}"


def documentation_path_from_target(target: str) -> str:
    if target.startswith("/documentation/"):
        return target.removeprefix("/documentation/").strip("/")
    if "/documentation/" in target:
        return target.split("/documentation/", 1)[-1].strip("/")
    return target.strip("/")


def register_lookup_keys(index: dict[str, str], rel_path: str) -> None:
    stem = rel_path.removesuffix(".md")
    keys = {
        stem,
        stem.lower(),
        sanitize_relative_path(stem),
        sanitize_relative_path(stem).lower(),
    }
    if stem.startswith("documentation/"):
        suffix = stem.removeprefix("documentation/")
        keys.update(
            {
                suffix,
                suffix.lower(),
                sanitize_relative_path(suffix),
                sanitize_relative_path(suffix).lower(),
            }
        )
    for key in keys:
        index[key.lower()] = rel_path


def build_path_index(root: Path) -> dict[str, str]:
    index: dict[str, str] = {}
    for md_path in root.rglob("*.md"):
        rel_path = md_path.relative_to(root).as_posix()
        register_lookup_keys(index, rel_path)
    return index


def resolve_markdown_path(doc_path: str, index: dict[str, str]) -> str | None:
    candidates = [
        doc_path,
        doc_path.lower(),
        sanitize_relative_path(doc_path),
        sanitize_relative_path(doc_path).lower(),
    ]
    if doc_path.lower().startswith("documentation/"):
        suffix = doc_path[len("documentation/") :]
        candidates.extend(
            [
                suffix,
                suffix.lower(),
                sanitize_relative_path(suffix),
                sanitize_relative_path(suffix).lower(),
            ]
        )

    for candidate in candidates:
        match = index.get(candidate.lower())
        if match:
            return match
    return None


def target_to_github_url(target: str, index: dict[str, str], blob_base: str) -> str | None:
    doc_path = documentation_path_from_target(target)
    if doc_path.endswith(".md"):
        doc_path = doc_path[:-3]

    rel_path = resolve_markdown_path(doc_path, index)
    if not rel_path:
        return None

    encoded = "/".join(quote(part, safe="()-_.") for part in rel_path.split("/"))
    return f"{blob_base}/{encoded}"


def doc_uri_to_link(identifier: str) -> str:
    if not identifier:
        return ""

    github_url = target_to_github_url(identifier, _path_index, _blob_base)
    if github_url:
        return github_url

    if identifier.startswith("/documentation/"):
        return identifier
    if identifier.startswith("doc://"):
        path = identifier.split("/documentation/", 1)[-1]
        return f"/documentation/{path}"
    return identifier


def rewrite_markdown_links(content: str) -> tuple[str, int]:
    replacements = 0

    def replace(match: re.Match[str]) -> str:
        nonlocal replacements
        target = match.group("target")
        github_url = target_to_github_url(target, _path_index, _blob_base)
        if not github_url:
            return match.group(0)
        replacements += 1
        return f"]({github_url})"

    return DOC_LINK_RE.sub(replace, content), replacements


def rewrite_all_markdown_links(markdown_dir: Path) -> tuple[int, int]:
    """Rewrite remaining DocC links in every markdown file."""
    link_replacements = 0
    link_updated_files = 0

    for md_path in sorted(markdown_dir.rglob("*.md")):
        original = md_path.read_text(encoding="utf-8")
        updated, count = rewrite_markdown_links(original)
        if updated != original:
            md_path.write_text(updated, encoding="utf-8")
            link_updated_files += 1
            link_replacements += count

    return link_replacements, link_updated_files


# ---------------------------------------------------------------------------
# Step 2: Enrich content from DocC render JSON
# ---------------------------------------------------------------------------


def inline_content_to_markdown(items: list | None) -> str:
    if not items:
        return ""

    parts: list[str] = []
    for item in items:
        item_type = item.get("type")
        if item_type == "text":
            parts.append(item.get("text", ""))
        elif item_type == "codeVoice":
            parts.append(f"`{item.get('code', '')}`")
        elif item_type == "reference":
            identifier = item.get("identifier", "")
            title = item.get("isActive", False) and item.get("title")
            if not title and identifier:
                title = identifier.rsplit("/", 1)[-1]
            parts.append(f"[`{title}`]({doc_uri_to_link(identifier)})")
        elif item_type == "strong":
            parts.append(f"**{inline_content_to_markdown(item.get('inlineContent'))}**")
        elif item_type == "emphasis":
            parts.append(f"*{inline_content_to_markdown(item.get('inlineContent'))}*")
        elif item_type == "paragraph":
            parts.append(inline_content_to_markdown(item.get("inlineContent")))
        elif item_type == "softBreak":
            parts.append("\n")
        elif item_type == "lineBreak":
            parts.append("\n")

    return "".join(parts)


def block_content_to_markdown(blocks: list | None) -> str:
    if not blocks:
        return ""

    paragraphs: list[str] = []
    for block in blocks:
        if block.get("type") == "paragraph":
            text = inline_content_to_markdown(block.get("inlineContent"))
            if text.strip():
                paragraphs.append(text)
        elif "inlineContent" in block:
            text = inline_content_to_markdown(block.get("inlineContent"))
            if text.strip():
                paragraphs.append(text)

    return "\n\n".join(paragraphs)


def doc_uri_to_title(identifier: str, references: dict) -> str:
    ref = references.get(identifier, {})
    if ref.get("title"):
        return ref["title"]
    if identifier.startswith("doc://"):
        return identifier.rsplit("/", 1)[-1]
    return identifier


def topic_entry_markdown(identifier: str, references: dict) -> str:
    ref = references.get(identifier, {})
    title = ref.get("title") or doc_uri_to_title(identifier, references)
    link = doc_uri_to_link(ref.get("url") or identifier)
    lines = [f"[`{title}`]({link})"]

    abstract = block_content_to_markdown(ref.get("abstract"))
    if abstract.strip():
        lines.extend(["", abstract])

    return "\n".join(lines)


def split_markdown(content: str) -> tuple[str, str]:
    if content.startswith("<!--"):
        end = content.find("-->")
        if end != -1:
            metadata = content[: end + 3]
            body = content[end + 3 :].lstrip("\n")
            return metadata, body
    return "", content


def has_section(body: str, title: str) -> bool:
    pattern = rf"^## {re.escape(title)}\s*$"
    return re.search(pattern, body, flags=re.MULTILINE) is not None


def body_contains_text(body: str, text: str) -> bool:
    normalized = " ".join(text.split())
    if not normalized:
        return True
    return normalized in " ".join(body.split())


def insert_after_title(body: str, insertion: str) -> str:
    lines = body.splitlines()
    if not lines:
        return insertion

    output: list[str] = []
    inserted = False
    for line in lines:
        output.append(line)
        if not inserted and line.startswith("# "):
            if insertion.strip():
                output.append("")
                output.extend(insertion.splitlines())
            inserted = True

    if not inserted:
        output.extend(["", insertion])

    return "\n".join(output).rstrip() + "\n"


def insert_before_code_fence(body: str, insertion: str) -> str:
    if not insertion.strip():
        return body

    marker = "\n```"
    index = body.find(marker)
    if index == -1:
        return body.rstrip() + "\n\n" + insertion + "\n"

    prefix = body[:index].rstrip()
    suffix = body[index:].lstrip("\n")
    return prefix + "\n\n" + insertion + "\n\n" + suffix


def enrich_body(body: str, doc: dict) -> str:
    references = doc.get("references", {})
    abstract = block_content_to_markdown(doc.get("abstract"))
    deprecation = block_content_to_markdown(doc.get("deprecationSummary"))

    if abstract.strip() and not body_contains_text(body, abstract):
        body = insert_after_title(body, abstract)

    if deprecation.strip() and not has_section(body, "Deprecated"):
        body = insert_before_code_fence(
            body,
            f"## Deprecated\n\n{deprecation}",
        )

    topic_sections = doc.get("topicSections") or []
    appended_sections: list[str] = []
    for section in topic_sections:
        title = section.get("title")
        identifiers = section.get("identifiers") or []
        if not title or not identifiers:
            continue
        if has_section(body, title):
            continue

        entries = [
            topic_entry_markdown(identifier, references)
            for identifier in identifiers
        ]
        appended_sections.append(f"## {title}\n\n" + "\n\n".join(entries))

    if appended_sections:
        body = body.rstrip() + "\n\n" + "\n\n".join(appended_sections) + "\n"

    return body


def parse_metadata_comment(metadata: str) -> dict:
    """Parse the JSON payload inside the leading <!-- ... --> comment."""
    if not metadata:
        return {}

    inner = metadata.strip()
    if inner.startswith("<!--"):
        inner = inner[len("<!--") :]
    if inner.endswith("-->"):
        inner = inner[: -len("-->")]

    try:
        return json.loads(inner.strip())
    except ValueError:
        return {}


def format_availability(entries: list | None) -> str:
    """Convert DocC availability entries to a compact human/agent-readable string.

    Examples:
      "iOS: 2.0.0 -"          -> "iOS 2.0.0+"
      "iOS: 2.0.0 - 5.0.0"    -> "iOS 2.0.0–5.0.0"
    """
    parts: list[str] = []
    for entry in entries or []:
        if ":" not in entry:
            continue
        platform, _, versions = entry.partition(":")
        platform = platform.strip()
        bounds = [segment.strip() for segment in versions.split("-")]
        introduced = bounds[0] if bounds else ""
        deprecated = bounds[1] if len(bounds) > 1 else ""

        if introduced and deprecated:
            parts.append(f"{platform} {introduced}–{deprecated}")
        elif introduced:
            parts.append(f"{platform} {introduced}+")
        else:
            parts.append(platform)
    return ", ".join(parts)


def metadata_summary_line(meta: dict) -> str:
    """Build a one-line visible summary from parsed metadata (role + availability)."""
    if not meta:
        return ""

    segments: list[str] = []
    role = meta.get("role") or (meta.get("symbol") or {}).get("kind")
    if role:
        segments.append(f"**{role}**")

    availability = format_availability(meta.get("availability"))
    if availability:
        segments.append(availability)

    return " · ".join(segments)


def enrich_markdown_file(md_path: Path, json_path: Path) -> bool:
    original = md_path.read_text(encoding="utf-8")
    metadata, body = split_markdown(original)
    new_body = body

    # Merge abstracts, deprecation notes, and topic sections from sibling JSON.
    if json_path.is_file():
        try:
            with json_path.open(encoding="utf-8") as handle:
                doc = json.load(handle)
        except ValueError:
            doc = {}
        if doc:
            new_body = enrich_body(new_body, doc)

    # Surface role + availability from the leading comment as a visible line so it
    # survives markdown rendering (HTML comments are stripped) and is read by agents.
    summary = metadata_summary_line(parse_metadata_comment(metadata))
    if summary and summary not in new_body:
        new_body = insert_after_title(new_body, summary)

    if new_body == body:
        return False

    md_path.write_text(
        (metadata + "\n\n" if metadata else "") + new_body,
        encoding="utf-8",
    )
    return True


def enrich_markdown_dir(markdown_dir: Path, data_dir: Path) -> int:
    enriched_count = 0
    for md_path in sorted(markdown_dir.rglob("*.md")):
        rel_path = md_path.relative_to(markdown_dir)
        json_path = data_dir / rel_path.with_suffix(".json")
        if enrich_markdown_file(md_path, json_path):
            enriched_count += 1
    return enriched_count


# ---------------------------------------------------------------------------
# Orchestration
# ---------------------------------------------------------------------------


def customise_markdown_dir(markdown_dir: Path, data_dir: Path) -> tuple[int, int, int, int]:
    global _path_index, _blob_base

    # Step 1: fix filenames before building the path index used for links.
    sanitized_count = sanitize_markdown_paths(markdown_dir)

    # Step 2: enrich using sibling JSON from the DocC archive.
    _path_index = build_path_index(markdown_dir)
    _blob_base = github_blob_base()
    enriched_count = enrich_markdown_dir(markdown_dir, data_dir)

    # Step 3: rewrite DocC links in both original and newly enriched content.
    link_replacements, link_updated_files = rewrite_all_markdown_links(markdown_dir)

    return sanitized_count, enriched_count, link_replacements, link_updated_files


def main() -> int:
    if len(sys.argv) != 3:
        print(
            "Usage: customise-md-docs.py <doccarchive> <markdown_dir>",
            file=sys.stderr,
        )
        return 1

    archive_dir = Path(sys.argv[1])
    markdown_dir = Path(sys.argv[2])
    data_dir = archive_dir / "data" / "documentation"

    if not markdown_dir.is_dir():
        print(f"Error: markdown directory not found at {markdown_dir}", file=sys.stderr)
        return 1

    sanitized_count, enriched_count, link_replacements, link_updated_files = (
        customise_markdown_dir(markdown_dir, data_dir)
    )

    if sanitized_count:
        print(f"Sanitized {sanitized_count} paths for artifact-compatible filenames")
    else:
        print("No markdown paths required sanitization")

    print(f"Enriched {enriched_count} Markdown files in {markdown_dir}")
    print(
        f"Rewrote {link_replacements} links in {link_updated_files} files "
        f"(base: {_blob_base})"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
