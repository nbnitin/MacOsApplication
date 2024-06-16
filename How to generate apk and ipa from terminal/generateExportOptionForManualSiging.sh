#!/bin/bash

# Function to create exportOptions.plist for manual signing
create_export_options_plist() {
    DISTRIBUTION_METHOD=$1
    TEAM_ID=$2
    BUNDLE_ID=$3
    PROVISIONING_PROFILE_UUID=$4
    SIGNING_CERTIFICATE=$5
    OUTPUT_PATH=$6

    # Create the plist content based on distribution method
    cat <<EOF > "$OUTPUT_PATH"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>$DISTRIBUTION_METHOD</string>
    <key>teamID</key>
    <string>$TEAM_ID</string>
    <key>signingStyle</key>
    <string>manual</string>
    <key>provisioningProfiles</key>
    <dict>
        <key>$BUNDLE_ID</key>
        <string>$PROVISIONING_PROFILE_UUID</string>
    </dict>
    <key>signingCertificate</key>
    <string>$SIGNING_CERTIFICATE</string>
</dict>
</plist>
EOF

    echo "exportOptions.plist created at $OUTPUT_PATH for $DISTRIBUTION_METHOD distribution with manual signing."
}

# Variables
DISTRIBUTION_METHOD=$1   # Change this to your desired distribution method "app-store-connect | debugging | ad-hoc"
TEAM_ID=$2         # Your Apple Developer Team ID
BUNDLE_ID=$3   # Your app's bundle identifier
PROVISIONING_PROFILE_UUID=$4   # UUID of your provisioning profile
SIGNING_CERTIFICATE="iOS Distribution"  # Name of your signing certificate
OUTPUT_PATH="./exportOptions.plist"   # Output path for exportOptions.plist



# Create exportOptions.plist for manual signing
create_export_options_plist $DISTRIBUTION_METHOD $TEAM_ID $BUNDLE_ID $PROVISIONING_PROFILE_UUID "$SIGNING_CERTIFICATE" $OUTPUT_PATH
