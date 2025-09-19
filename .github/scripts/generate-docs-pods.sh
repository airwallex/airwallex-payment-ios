#!/bin/bash

# Documentation generation script for Airwallex iOS SDK using Pods project

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
    -configuration Release

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

echo "Documentation generated in ./docs/html"
echo "Redirect index.html created in ./docs/redirect/"