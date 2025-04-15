#!/bin/sh

set -e

if [ -n "$CI" ]; then
    echo "Skip - generate symbolic links for CI."
    exit 0
fi

AIRWALLEX_CORE_PUBLIC_HEADER_PATH="${SRCROOT}/../Airwallex/AirwallexCore/include"
AIRWALLEX_CORE_SOURCE_RELATIVE_PATH="../Sources"

rm -rf $AIRWALLEX_CORE_PUBLIC_HEADER_PATH/*.*

echo "Generate symbolic links for AirwallexCore public headers under ${AIRWALLEX_CORE_PUBLIC_HEADER_PATH}"

cd $AIRWALLEX_CORE_PUBLIC_HEADER_PATH
public_headers_list=$(
    find "$AIRWALLEX_CORE_SOURCE_RELATIVE_PATH" \
        -type f -name "*.[h]" \
        -not -path "$AIRWALLEX_CORE_SOURCE_RELATIVE_PATH/Internal/*" \
        | sed "s| \([^/]\)|:\1|g"
)

for public_file in $public_headers_list; do
    echo "symbolic link: $public_file"
    file_to_link=$(echo $public_file | sed "s|:| |g")
    ln -s $file_to_link
done
cd $SRCROOT

echo "      Done"
