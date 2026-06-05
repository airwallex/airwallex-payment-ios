#!/usr/bin/env python3
"""Rename markdown outputs so paths are safe for GitHub Actions artifacts (NTFS)."""

from __future__ import annotations

import sys
from pathlib import Path

# https://github.com/actions/toolkit/blob/main/packages/artifact/docs/faq.md
INVALID_PATH_CHARS = '":<>|*?\r\n'


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


def main() -> int:
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <markdown_dir>", file=sys.stderr)
        return 1

    root = Path(sys.argv[1])
    if not root.is_dir():
        print(f"Error: not a directory: {root}", file=sys.stderr)
        return 1

    renames = collect_file_renames(root)
    if not renames:
        print("No markdown paths required sanitization")
        return 0

    apply_renames(renames)
    update_text_references(root, renames)
    print(f"Sanitized {len(renames)} paths for artifact-compatible filenames")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
