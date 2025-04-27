xcodebuild -exportLocalizations -project ../Airwallex/Airwallex.xcodeproj -localizationPath exported
python3 xliff2csv.py
