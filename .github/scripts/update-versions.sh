#!/usr/bin/env bash
set -euo pipefail

if [ -z "${VERSION}" ]; then
  echo "Missing version."
  exit 1
fi

echo "Updating version to $VERSION."
sed -i '' 's/\(AIRWALLEX_VERSION (@"\)[^"]*/\1'"$VERSION"'/g' ./Airwallex/AirwallexCore/Sources/AWXConstants.h
sed -i '' 's/\(s.version *= *"\)[^"]*/\1'"$VERSION"'/g' ./Airwallex.podspec
sed -i '' 's/\(AIRWALLEX_VERSION *= *\).*/\1'"$VERSION"'/g' ./Airwallex/Airwallex.xcconfig

echo "Updating documentation URLs in README files."
# Update documentation URLs in README.md and README_zh_CN.md
sed -i '' 's|github\.io/airwallex-payment-ios/[^/]*/|github.io/airwallex-payment-ios/'"$VERSION"'/|g' ./README.md
sed -i '' 's|github\.io/airwallex-payment-ios/[^/]*/|github.io/airwallex-payment-ios/'"$VERSION"'/|g' ./README_zh_CN.md

# Update Podfile.lock used by the demo app.
# This currently takes a lot of time. We need to find a way
# to bypass the step.
echo "Running pod repo update."
pod repo update

echo "Running pod install."
pod install