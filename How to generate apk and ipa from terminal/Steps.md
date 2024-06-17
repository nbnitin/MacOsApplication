How to generate debug APK, and ipa file without using any third party tool demo attached ?
# Android
./gradlew assembleDebug --- for apk<br/> 
./gradlew assembleRelease --- for release apk<br/>
./gradlew bundleRelease --- for aab<br/>

__generate keystore file__
sudo keytool -genkey -v -keystore my-upload-key.keystore -alias my-key-alias -keyalg RSA -keysize 2048 -validity 10000<br/> 
sudo keytool -genkey -v -keystore my-upload-key.jks -alias my-key-alias -keyalg RSA -keysize 2048 -validity 10000<br/> 

__Sign aab file__
jarsigner -keystore my-upload-key.keystore -storepass nbNitin@123 -keypass nbNitin@123 app-release.aab my-key-alias<br/> 
jarsigner -keystore my-upload-key.jks -storepass nbNitin@123 -keypass nbNitin@123 app-release.aab my-key-alias<br/> 

return of both command <br/> 
jar signed.<br/> 

__To verify__
jarsigner -verify app-release.aab<br/> 
jar verified.<br/> 

you will find the (.aab) file inside output release folder and .apk in apk/debug folder
# iOS
 __Add Privacy Manifest File to Your Xcode Project:__

* Open your Xcode project.
* Drag the PrivacyInfo.xcprivacy file into your project in the Xcode file navigator.
* Make sure the file is included in the appropriate target by checking the target membership in the file inspector.

You need to generate archive file for it first<br/>
`xcodebuild -workspace YOUR_WORKSPACE.xcworkspace -scheme YOUR_SCHEME -configuration Release -archivePath /path/to/archive archive`<br/>
for xcodeproj<br/>
`xcodebuild -project YOUR PROJECT NAME.xcodeproj -scheme YOUR SCHEME -configuration Release -archivePath /path/to archive archive`<br/>
`xcodebuild -project SplineSample.xcodeproj -scheme SplineSample -configuration Release -archivePath sm.xcarchive archive`  <br/>
Generate export options plist<br/>
script added<br/>
Convert archive to ipa<br/>
`xcodebuild -exportArchive -archivePath /path/to/archive -exportPath /path/to/export (just folder name) -exportOptionsPlist ./exportOptions.plist.`<br/>
`xcodebuild -exportArchive -archivePath sm.xcarchive -exportPath ./m -exportOptionsPlist ./exportOptions.plist`<br/>

