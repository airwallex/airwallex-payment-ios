python3 csv2xliff.py
find updated/ -type f ! -name '*.xliff' -delete
# find all files in updated/ directory and execute xcodebuild -importLocalizations for each file
for file in updated/*.xliff; do
  echo "Importing $file"
  xcodebuild -importLocalizations -localizationPath "$file" -project ../Airwallex/Airwallex.xcodeproj
done
