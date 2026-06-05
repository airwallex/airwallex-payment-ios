#!/bin/bash

# Extract Markdown documentation from a DocC archive.
# Requires DocC built with --enable-experimental-markdown-output.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ARCHIVE="${1:?Usage: extract-markdown-from-doccarchive.sh <doccarchive> [output_dir]}"
OUTPUT_DIR="${2:-md-docs}"

if [ ! -d "$ARCHIVE" ]; then
    echo "Error: DocC archive not found at $ARCHIVE"
    exit 1
fi

rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

DATA_DIR="$ARCHIVE/data/documentation"
MARKDOWN_COUNT=0

if [ -d "$DATA_DIR" ]; then
    while IFS= read -r -d '' md_file; do
        rel_path="${md_file#$DATA_DIR/}"
        dest="$OUTPUT_DIR/$rel_path"
        mkdir -p "$(dirname "$dest")"
        cp "$md_file" "$dest"
        MARKDOWN_COUNT=$((MARKDOWN_COUNT + 1))
    done < <(find "$DATA_DIR" -name '*.md' -type f -print0)
fi

for manifest in \
    "$ARCHIVE/markdown-manifest.json" \
    "$ARCHIVE/data/markdown-manifest.json" \
    "$ARCHIVE/manifest.json"
do
    if [ -f "$manifest" ]; then
        cp "$manifest" "$OUTPUT_DIR/manifest.json"
        break
    fi
done

if [ "$MARKDOWN_COUNT" -eq 0 ]; then
    echo "Warning: No Markdown files found in $ARCHIVE"
    echo "Ensure docbuild was run with OTHER_DOCC_FLAGS=\"--enable-experimental-markdown-output --enable-experimental-markdown-output-manifest\""
    exit 1
fi

"$SCRIPT_DIR/customise-md-docs.py" "$ARCHIVE" "$OUTPUT_DIR"

# Generate a package-list index similar to Dokka for downstream tooling.
PACKAGE_LIST="$OUTPUT_DIR/package-list"
{
    echo '$docc.format:markdown-v1'
    echo '$docc.linkExtension:md'
    while IFS= read -r -d '' md_file; do
        rel_path="${md_file#$OUTPUT_DIR/}"
        echo "\$docc.location:$rel_path"
    done < <(find "$OUTPUT_DIR" -name '*.md' -type f -print0 | sort -z)
} > "$PACKAGE_LIST"

echo "Extracted $MARKDOWN_COUNT Markdown files to $OUTPUT_DIR"
