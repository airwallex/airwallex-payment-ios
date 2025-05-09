#!/bin/bash

# remove exported directory if it exists
rm -r exported

# export all localizations from the project
xcodebuild -exportLocalizations -project ../Airwallex/Airwallex.xcodeproj -localizationPath exported \
    -exportLanguage de \
    -exportLanguage en \
    -exportLanguage es \
    -exportLanguage fr \
    -exportLanguage ja \
    -exportLanguage ko \
    -exportLanguage pt-BR \
    -exportLanguage pt-PT \
    -exportLanguage ru \
    -exportLanguage th \
    -exportLanguage zh-Hans \
    -exportLanguage zh-Hant
    # not sure why but if we don't specify the languages, it will export only en

# convert the exported xliff files to csv
python3 xliff2csv.py
