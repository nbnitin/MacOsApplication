#!/bin/bash

# Define the path to your Info.plist file
INFO_PLIST="/Users/nitin.bhatia/Documents/DaxkoProjects/ReactNative/Expo/my-app/ios/Nits/Info.plist"

# Function to add entries to the Info.plist file
add_entry() {
    /usr/libexec/PlistBuddy -c "$1" "$INFO_PLIST"
}

# Add CFBundleIcons entry
add_entry "Add :CFBundleIcons dict"

# Add CFBundleAlternateIcons entry
add_entry "Add :CFBundleIcons:CFBundleAlternateIcons dict"

# Add each logo entry
for i in {1..9}; do
    add_entry "Add :CFBundleIcons:CFBundleAlternateIcons:logo_${i} dict"
    add_entry "Add :CFBundleIcons:CFBundleAlternateIcons:logo_${i}:UIPrerenderedIcon bool false"
    add_entry "Add :CFBundleIcons:CFBundleAlternateIcons:logo_${i}:CFBundleIconFiles array"
    add_entry "Add :CFBundleIcons:CFBundleAlternateIcons:logo_${i}:CFBundleIconFiles:$((i-1)) string logo_${i}"
done

# Add CFBundlePrimaryIcon entry
add_entry "Add :CFBundleIcons:CFBundlePrimaryIcon dict"
add_entry "Add :CFBundleIcons:CFBundlePrimaryIcon:CFBundleIconName string"
add_entry "Add :CFBundleIcons:CFBundlePrimaryIcon:CFBundleIconFiles array"
add_entry "Add :CFBundleIcons:CFBundlePrimaryIcon:CFBundleIconFiles:0 string logo_1"
add_entry "Add :CFBundleIcons:CFBundlePrimaryIcon:UIPrerenderedIcon bool false"

# Add UINewsstandIcon entry
add_entry "Add :CFBundleIcons:UINewsstandIcon dict"
add_entry "Add :CFBundleIcons:UINewsstandIcon:CFBundleIconFiles array"
add_entry "Add :CFBundleIcons:UINewsstandIcon:CFBundleIconFiles:0 string logo_1"
add_entry "Add :CFBundleIcons:UINewsstandIcon:UINewsstandBindingType string UINewsstandBindingTypeMagazine"
add_entry "Add :CFBundleIcons:UINewsstandIcon:UINewsstandBindingEdge string UINewsstandBindingEdgeLeft"

