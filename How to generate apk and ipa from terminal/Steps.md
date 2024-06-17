How to generate debug APK, and ipa file without using any third party tool demo attached ?
# Android
./gradlew assembleDebug --- for apk<br/> 
./gradlew bundleRelease --- for aab<br/>

generate keystore file
sudo keytool -genkey -v -keystore my-upload-key.keystore -alias my-key-alias -keyalg RSA -keysize 2048 -validity 10000

you will find the (.aab) file inside output release folder and .apk in apk/debug folder
# iOS
You need to generate archive file for it first
`xcodebuild -workspace YOUR_WORKSPACE.xcworkspace -scheme YOUR_SCHEME -configuration Release -archivePath /path/to/archive archive`<br/>
for xcodeproj<br/>
`xcodebuild -project YOUR PROJECT NAME.xcodeproj -scheme YOUR SCHEME -configuration Release -archivePath /path/to archive archive`<br/>
`xcodebuild -project SplineSample.xcodeproj -scheme SplineSample -configuration Release -archivePath sm.xcarchive archive`  <br/>
`xcodebuild -exportArchive -archivePath sm.xcarchive -exportPath ./m -exportOptionsPlist ./exportOptions.plist`<br/>
Generate export options plist<br/>
script added<br/>
Convert archive to ipa<br/>
`xcodebuild -exportArchive -archivePath /path/to/archive -exportPath /path/to/export (just folder name) -exportOptionsPlist ./exportOptions.plist.`
