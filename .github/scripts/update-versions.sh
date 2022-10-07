#!/usr/bin/env bash
set -euo pipefail

if [ -z "${VERSION}" ]; then
  echo "Missing version."
  exit 1
fi

echo "Updating version to $VERSION."
sed -i '' 's/\(AIRWALLEX_VERSION (@"\)[^"]*/\1'"$VERSION"'/g' ./Airwallex/Core/Sources/AWXConstants.h
sed -i '' 's/\(s.version *= *"\)[^"]*/\1'"$VERSION"'/g' ./Airwallex.podspec
sed -i '' 's/\(AIRWALLEX_VERSION *= *\).*/\1'"$VERSION"'/g' ./Airwallex/Airwallex.xcconfig

# Update Podfile.lock used by the demo app.
# This currently takes a lot of time. We need to find a way
# to bypass the step.
echo "Running pod repo update."
pod repo update

echo "Running pod install."
pod install