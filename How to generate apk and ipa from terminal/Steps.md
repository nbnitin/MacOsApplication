How to generate debug APK, and ipa file without using any third party tool demo attached ?
# Android
./gradlew assembleDebug
# iOS
You need to generate archive file for it first
`xcodebuild -workspace YOUR_WORKSPACE.xcworkspace -scheme YOUR_SCHEME -configuration Release -archivePath /path/to/archive archive`
Generate export options plist
script attached
Convert archive to ipa
`xcodebuild -exportArchive -archivePath /path/to/archive -exportPath /path/to/export (just folder name) -exportOptionsPlist ./exportOptions.plist.`
