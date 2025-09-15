#!/bin/bash

# Simple documentation generation script for Airwallex iOS SDK

set -e

# Check if LATEST_VERSION is set
if [ -z "$LATEST_VERSION" ]; then
    echo "Error: LATEST_VERSION environment variable is required but not set"
    echo "Please provide a version (e.g., LATEST_VERSION=1.0.0)"
    exit 1
fi

echo "Building documentation for version: $LATEST_VERSION"

# Prepare 
rm -rf DerivedData
rm -rf docs
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
    transform-for-static-hosting docs/Airwallex.doccarchive \
    --output-path ./docs/html/ \
    --hosting-base-path "/airwallex-payment-ios/$LATEST_VERSION" \
    # --hosting-base-path "/airwallex-payment-ios"

# Create redirect index.html under docs/
mkdir -p docs/redirect

cat > docs/redirect/index.html << EOF
<!DOCTYPE html>
<html>
<head>
  <script>
    // Extract the path after /airwallex-payment-ios/documentation/airwallex
    const currentPath = window.location.pathname;
    const basePath = '/airwallex-payment-ios/documentation/airwallex';
    
    if (currentPath.startsWith(basePath)) {
      const subPath = currentPath.substring(basePath.length);
      const newPath = '/airwallex-payment-ios/$LATEST_VERSION/documentation/airwallex' + subPath;
      window.location.replace(newPath);
    } else {
      // Fallback redirect
      window.location.replace('/airwallex-payment-ios/$LATEST_VERSION/documentation/airwallex');
    }
  </script>
  <noscript>
    <meta http-equiv="Refresh" content="0; url='/airwallex-payment-ios/$LATEST_VERSION/documentation/airwallex'" />
  </noscript>
</head>
<body>
  <p>Redirecting to the latest documentation...</p>
</body>
</html>
EOF

# Cleanup
mv Airwallex/Airwallex/Airwallex.docc .

echo "Documentation generated in ./docs/"
echo "Redirect index.html created in ./docs/redirect/"