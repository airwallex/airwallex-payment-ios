#!/bin/bash

# Simple documentation generation script for Airwallex iOS SDK

set -e

# Prepare 
rm -rf DerivedData
mkdir -p docs
mv Airwallex.docc Airwallex/Airwallex/

# Temporarily hide workspace to force Package.swift build
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
    transform-for-static-hosting DerivedData/Build/Products/Release-iphoneos/Airwallex.doccarchive \
    --output-path ./docs/html/ \
    --hosting-base-path "/airwallex-payment-ios/$LATEST_VERSION" \
    # --hosting-base-path "/airwallex-payment-ios"

# Create redirect index.html under docs/
cat > docs/index.html << EOF
<head>
  <meta http-equiv="Refresh" content="0; url='/airwallex-payment-ios/$LATEST_VERSION/documentation/airwallex'" />
</head>
EOF

# Cleanup
mv Airwallex/Airwallex/Airwallex.docc .

echo "Documentation generated in ./docs/"
echo "Redirect index.html created in ./docs/"