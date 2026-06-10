#!/bin/bash

# Documentation generation script for Airwallex iOS SDK using Pods project

set -e

# Accept VERSION as command line argument or environment variable
if [ $# -eq 1 ]; then
    VERSION="$1"
elif [ -n "${VERSION:-}" ]; then
    VERSION="${VERSION}"
else
    # Read version from Airwallex.podspec
    PODSPEC_PATH="Airwallex.podspec"
    if [ -f "$PODSPEC_PATH" ]; then
        VERSION=$(grep -E '^\s*s\.version\s*=' "$PODSPEC_PATH" | sed -E 's/.*"([^"]+)".*/\1/')
        if [ -z "$VERSION" ]; then
            echo "✗ Error: Could not extract version from $PODSPEC_PATH"
            exit 1
        fi
        echo "Using version from $PODSPEC_PATH: $VERSION"
    else
        echo "Usage: $0 <version> or set VERSION environment variable"
        echo "Example: $0 1.0.0 or VERSION=1.0.0 $0"
        echo "Alternatively, ensure Airwallex.podspec exists in the current directory"
        exit 1
    fi
fi

echo "Building documentation for version: $VERSION"

docc_supports_markdown_output() {
    xcrun docc convert --help 2>&1 | grep -q "enable-experimental-markdown-output"
}

DOCC_FLAGS=""
if [ "${REQUIRE_MARKDOWN_DOCS:-}" = "true" ]; then
    if docc_supports_markdown_output; then
        DOCC_FLAGS="--enable-experimental-markdown-output --enable-experimental-markdown-output-manifest"
    else
        echo "✗ Error: DocC markdown output is not available in this Xcode version"
        echo "  Requires Xcode 26.4+ (see: xcrun docc convert --help | grep markdown)"
        echo "  For CI, use runs-on: macos-26 and xcode-version: '26.4' or newer in deploy-md-docs.yml"
        exit 1
    fi
fi

# Prepare 
rm -rf DerivedData/*
rm -rf docs/*
rm -rf md-docs
mkdir -p docs

# Check if Airwallex.docc has been added as compile source to Pods project
echo "Checking if Airwallex.docc is added to Pods project..."

PODS_PROJECT="Pods/Pods.xcodeproj/project.pbxproj"

if [ -f "$PODS_PROJECT" ]; then
    # Check if Airwallex.docc is referenced in the Pods project
    if grep -q "Airwallex.docc" "$PODS_PROJECT"; then
        echo "✓ Airwallex.docc found in Pods project - proceeding with documentation build"
    else
        echo "✗ Error: Airwallex.docc not found in Pods project"
        echo "Please manually add Airwallex.docc as a compile source to the Airwallex target in Pods project"
        echo "1. Open Airwallex.xcworkspace in Xcode"
        echo "2. Navigate to Pods project > Airwallex target"
        echo "3. Add Airwallex.docc to the compile sources"
        exit 1
    fi
else
    echo "✗ Error: Pods project not found at $PODS_PROJECT"
    echo "Please run 'pod install' first"
    exit 1
fi

# Build documentation using Pods project
xcodebuild docbuild \
    -workspace Airwallex.xcworkspace \
    -scheme Airwallex \
    -destination "generic/platform=iOS" \
    -derivedDataPath DerivedData \
    -configuration Release \
    OTHER_DOCC_FLAGS="$DOCC_FLAGS"

# Move the new DocC archive to the its final place
mv "DerivedData/Build/Products/Release-iphoneos/Airwallex/Airwallex.doccarchive" "docs/Airwallex.doccarchive"

# Transform for static hosting
"$(xcrun --find docc)" process-archive \
    transform-for-static-hosting docs/Airwallex.doccarchive \
    --output-path ./docs/html/ \
    --hosting-base-path "/airwallex-payment-ios/$VERSION"

# Create redirect index.html under docs/
mkdir -p docs/redirect

cat > docs/redirect/index.html << EOF
<head>
  <meta http-equiv="Refresh" content="0; url='/airwallex-payment-ios/$VERSION/documentation/airwallex'" />
</head>
EOF

if [ -n "$DOCC_FLAGS" ]; then
    "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/extract-markdown-from-doccarchive.sh" docs/Airwallex.doccarchive md-docs
elif [ "${REQUIRE_MARKDOWN_DOCS:-}" = "true" ]; then
    echo "✗ Error: Markdown output is required but DocC markdown flags are not available"
    exit 1
fi

if [ "${REQUIRE_MARKDOWN_DOCS:-}" = "true" ]; then
    if [ -z "$(find md-docs -name '*.md' -print -quit 2>/dev/null)" ]; then
        echo "✗ Error: REQUIRE_MARKDOWN_DOCS is set but no .md files were produced in md-docs/"
        exit 1
    fi
fi

echo "Documentation generated in ./docs/html"
echo "Redirect index.html created in ./docs/redirect/"

# # Commit and push to reference-doc branch
# if [ "${CI:-}" != "true" ]; then
#     echo "Committing and pushing documentation changes..."
#     git add docs/
#     git commit -m "doc: $VERSION"
#     git push origin reference-doc

#     echo "✓ Documentation committed and pushed to reference-doc branch"
# fi
