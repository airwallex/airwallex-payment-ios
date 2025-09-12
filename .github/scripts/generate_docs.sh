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
    -skipPackagePluginValidation

# Restore workspace
mv Airwallex.xcworkspace.tmp Airwallex.xcworkspace

# Transform for static hosting
"$(xcrun --find docc)" process-archive \
    transform-for-static-hosting DerivedData/Build/Products/Debug-iphoneos/Airwallex.doccarchive \
    --output-path ./docs/ \
    --hosting-base-path "/airwallex-payment-ios"
    # --hosting-base-path "/airwallex-payment-ios/$LATEST_VERSION"

# Create redirect index.html under docs/
cat > docs/index.html << EOF
<head>
  <meta http-equiv="Refresh" content="0; url='/airwallex-payment-ios/documentation/airwallex'" />
</head>
EOF

# Cleanup
mv Airwallex/Airwallex/Airwallex.docc .

echo "Documentation generated in ./docs/"
echo "Redirect index.html created in ./docs/"