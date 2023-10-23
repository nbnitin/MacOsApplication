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


one more way to do it
productbuild --component "component-path" "install-path" "/path/to/product-output-path/packagename.pkg"

productbuild --compoenent "/Desktop/appContainerFolderName/sample.app" "/Applications" "/Desktop/latest.pkg"(compoenent takes path including .app)




