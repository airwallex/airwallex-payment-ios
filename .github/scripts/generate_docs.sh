#!/bin/bash

# Simple documentation generation script for Airwallex iOS SDK

set -e

rm -rf DerivedData
mkdir -p docs

# Build documentation

xcodebuild docbuild \
    -scheme Airwallex \
    -destination "generic/platform=iOS" \
    -derivedDataPath DerivedData \
    -skipPackagePluginValidation

# Transform for static hosting
"$(xcrun --find docc)" process-archive \
    transform-for-static-hosting DerivedData/Build/Products/Debug-iphoneos/Airwallex/Airwallex.doccarchive \
    --output-path ./docs/html

# Create redirect index.html under docs/
cat > docs/index.html << EOF
<head>
  <meta http-equiv="Refresh" content="0; url='/airwallex-payment-ios/$LATEST_VERSION/documentation/airwallex'" />
</head>
EOF

echo "Documentation generated in ./docs/html"
echo "Redirect index.html created in ./docs/"