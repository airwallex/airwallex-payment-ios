#!/bin/bash

# Simple documentation generation script for Airwallex iOS SDK

set -e

# Accept VERSION as command line argument or environment variable
if [ $# -eq 1 ]; then
    VERSION="$1"
elif [ -n "${VERSION:-}" ]; then
    VERSION="${VERSION}"
else
    echo "Usage: $0 <version> or set VERSION environment variable"
    echo "Example: $0 1.0.0 or VERSION=1.0.0 $0"
    exit 1
fi

echo "Building documentation for version: $VERSION"

# Prepare 
rm -rf DerivedData/*
rm -rf docs/*
mkdir -p docs
mv Airwallex.docc Airwallex/Airwallex/

# Temporarily hide workspace to force Package.swift build
rm -rf Airwallex.xcworkspace.tmp
mv Airwallex.xcworkspace Airwallex.xcworkspace.tmp

# Build documentation

xcodebuild docbuild \
    -scheme Airwallex \
    -destination "generic/platform=iOS" \
    -derivedDataPath DerivedData \
    -skipPackagePluginValidation \
    -configuration Release \

# Restore workspace
mv Airwallex.xcworkspace.tmp Airwallex.xcworkspace

# Move the new DocC archive to the its final place
mv "DerivedData/Build/Products/Release-iphoneos/Airwallex.doccarchive" "docs/Airwallex.doccarchive"

# Transform for static hosting
"$(xcrun --find docc)" process-archive \
    transform-for-static-hosting docs/Airwallex.doccarchive \
    --output-path ./docs/html/ \
    --hosting-base-path "/airwallex-payment-ios/$VERSION" \
    # --hosting-base-path "/airwallex-payment-ios"

# Create redirect index.html under docs/
mkdir -p docs/redirect

cat > docs/redirect/index.html << EOF
<head>
  <meta http-equiv="Refresh" content="0; url='/airwallex-payment-ios/$VERSION/documentation/airwallex'" />
</head>
EOF

# Cleanup
mv Airwallex/Airwallex/Airwallex.docc .

echo "Documentation generated in ./docs/html"
echo "Redirect index.html created in ./docs/redirect/"