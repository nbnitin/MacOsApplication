# Create .pkg or package installer for mac os application (.app)


1. Archive your app, and copy app to some location like (Desltop/appContainerFolderName/sample.app)
2. Create a folder name with any in desktop (I choosed Script ScriptPackage)
3. Open terminal cd /Desktop
4. cd ScriptPackage
5. mkdir Scripts
6. cd Scripts
7. touch postinstall(without any extension)
8. vim postinstall -> write your script with shebang sybmole at top (#!/bin/sh)
9. save it
10. chmod a+x postinstall
11. cd ..
12. sudo pkgbuild --root ../appContainerFolderName --install-location /Applications  --identifier bundleid --nopayload --script Scripts latest.pkg (we are running this command under ScriptPackage folder, --root dont take path with .app extension )

Terminal should report:

pkgbuild: Adding top-level postinstall script
pkgbuild: Wrote package to com.meraki.scriptsonly.pkg

 Your script must return 0 on success and any other number to denote failure. The name of the scripts must be “preinstall” and “postinstall”. You can see some sample scripts below-
#!/bin/sh

cd /Applications && mkdir hello11

exit 0;



one more way to do it
productbuild --component "component-path" "install-path" "/path/to/product-output-path/packagename.pkg"

productbuild --compoenent "/Desktop/appContainerFolderName/sample.app" "/Applications" "/Desktop/latest.pkg"(compoenent takes path including .app)



Building your package : PLIST / XML (or other files)
Open Terminal

 

Using mkdir Create a Directory. I’ve used PlistPackage as the Example

 

mkdir PlistPackage
cd PlistPackage
mkdir Scripts
mkdir Content
cd Scripts
touch postinstall


Copy the file(s) you need into the Content Folder

 

Using a text editor, edit the postinstall file and paste in your script that will move files in /tmp (we set where the installer will deposit the files in a following command) to where ever you need to

 

In Terminal

 

chmod a+x postinstall
cd ..
 

Build the package

 

sudo pkgbuild --identifier com.meraki.plistonly --root Content --script Scripts --install-location /tmp com.meraki.plistonly.pkg
Note: The above is similar to the previous example. We’ve removed the --nopayload flag and replaced it with --root Content to indicate that there’s a folder with content in 

 

Double Note: ensure that there is a space between /tmp and com.meraki.plistonly.pkg

 

Terminal reports:

 

sudo pkgbuild --identifier com.meraki.plistonly --root Content --script Scripts --install-location /tmp com.meraki.plistonly.pkg
pkgbuild: Inferring bundle components from contents of Content
pkgbuild: Adding top-level postinstall script
pkgbuild: Wrote package to com.meraki.plistonly.pkg
 
Building your package : DMG / PKG (silent installer)
Open Terminal

Using mkdir Create a Directory. I’ve used InstallerPackage as the Example

 

mkdir InstallerPackage
cd InstallerPackage
mkdir Scripts
mkdir Content
cd Scripts
touch postinstall
 

Copy the DMG  you need into the Content Folder

Using a text editor, edit the postinstall file and paste in your script that will move files in /tmp to where ever you need to

 

In Terminal

 

chmod a+x postinstall
cd ..
 

Build the package:

 

sudo pkgbuild --identifier com.meraki.dmg --root Content --script Scripts --install-location /tmp com.meraki.dmg.pkg
 

Terminal will report:

 

pkgbuild: Inferring bundle components from contents of Content
pkgbuild: Adding top-level postinstall script
pkgbuild: Wrote package to com.meraki.plistonly.pkg
 

An example postflight to move an app from a mounted DMG to /Applications:
#!/bin/bash

dmgPath="/tmp/YourDMGName.dmg"
mountPath="/Volumes/YourDMGMounted"
currentuser="$(id -un)"
usersAppDir="$(sudo -u $currentuser echo $HOME)"

/usr/bin/hdiutil attach "$dmgPath" -nobrowse -quiet
		
if [[ -e "$mountPath" ]]
	then
		cp -r "$mountPath"/"YourApp.app" /Applications/"YourAppName.app"
fi

umount "$mountPath"

rm -rf "$dmgPath"

# insert the commands that you need to
# provision your application

exit 0
 

An example postflight to move an app from a mounted DMG to /Applications where the DMG install expects user input
CaptureOne. for example, requests the user accept some EULA when opening the DMG. You can script this acceptance in your postflight:

 

#!/bin/bash

dmgPath="/tmp/CaptureOne12.Mac.12.1.4.dmg"
mountPath="/Volumes/Capture One 12"

/usr/bin/expect<<EOF
		spawn /usr/bin/hdiutil attach "$dmgPath" -nobrowse -quiet
		expect ":"
		send -- "G"
		expect ""
		send -- "\n"
		expect "Agree Y/N?"
		send -- "Y\n"
		expect EOF
EOF

if [[ -e "$mountPath" ]]
	then
		cp -r "$mountPath"/"Capture One 12.app" /Applications/"Capture One 12.app"
fi

umount "$mountPath"

exit 0
 

We use the EXPECT command to wait for the prompt, and SEND to send user input.

 




