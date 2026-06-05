#!/usr/bin/env python3
"""Enrich DocC markdown files with content from sibling render JSON files."""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path


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


def doc_uri_to_link(identifier: str) -> str:
    if not identifier:
        return ""
    if identifier.startswith("/documentation/"):
        return identifier
    if identifier.startswith("doc://"):
        # doc://org.cocoapods.Airwallex/documentation/Airwallex/AWXAPIClient
        path = identifier.split("/documentation/", 1)[-1]
        return f"/documentation/{path}"
    return identifier


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


def enrich_markdown_file(md_path: Path, json_path: Path) -> bool:
    if not json_path.is_file():
        return False

    with json_path.open(encoding="utf-8") as handle:
        doc = json.load(handle)

    original = md_path.read_text(encoding="utf-8")
    metadata, body = split_markdown(original)
    enriched_body = enrich_body(body, doc)

    if enriched_body == body:
        return False

    md_path.write_text(
        (metadata + "\n\n" if metadata else "") + enriched_body,
        encoding="utf-8",
    )
    return True


def main() -> int:
    if len(sys.argv) != 3:
        print(
            "Usage: enrich-markdown-from-doccarchive.py <doccarchive> <markdown_dir>",
            file=sys.stderr,
        )
        return 1

    archive_dir = Path(sys.argv[1])
    markdown_dir = Path(sys.argv[2])
    data_dir = archive_dir / "data" / "documentation"

    if not markdown_dir.is_dir():
        print(f"Error: markdown directory not found at {markdown_dir}", file=sys.stderr)
        return 1

    enriched_count = 0
    for md_path in sorted(markdown_dir.rglob("*.md")):
        rel_path = md_path.relative_to(markdown_dir)
        json_path = data_dir / rel_path.with_suffix(".json")
        if enrich_markdown_file(md_path, json_path):
            enriched_count += 1

    print(f"Enriched {enriched_count} Markdown files in {markdown_dir}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
