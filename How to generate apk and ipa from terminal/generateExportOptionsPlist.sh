#!/bin/bash

# Function to create exportOptions.plist
create_export_options_plist() {
    DISTRIBUTION_METHOD=$1
    TEAM_ID=$2
    OUTPUT_PATH=$3
    # Create the plist content based on distribution method
    case $DISTRIBUTION_METHOD in
    
            development)
            cat <<EOF > "$OUTPUT_PATH"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>debubbing</string>
    <key>teamID</key>
    <string>$TEAM_ID</string>
    <key>uploadBitcode</key>
    <true/>
    <key>compileBitcode</key>
    <true/>
</dict>
</plist>
EOF
            ;;
        
    
        app-store)
            cat <<EOF > "$OUTPUT_PATH"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store-connect</string>
    <key>teamID</key>
    <string>$TEAM_ID</string>
    <key>uploadBitcode</key>
    <true/>
    <key>compileBitcode</key>
    <true/>
   
</dict>
</plist>
EOF
            ;;
        ad-hoc)
            cat <<EOF > "$OUTPUT_PATH"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>ad-hoc</string>
    <key>teamID</key>
    <string>$TEAM_ID</string>
    
</dict>
</plist>
EOF
            ;;
        enterprise)
            cat <<EOF > "$OUTPUT_PATH"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>enterprise</string>
    <key>teamID</key>
    <string>$TEAM_ID</string>
  
</dict>
</plist>
EOF
            ;;
        *)
            echo "Unsupported distribution method: $DISTRIBUTION_METHOD"
            exit 1
            ;;
    esac

    echo "exportOptions.plist created at $OUTPUT_PATH for $DISTRIBUTION_METHOD distribution."
}

# Variables
DISTRIBUTION_METHOD=$1   # e.g., app-store, ad-hoc, enterprise
TEAM_ID=$2               # Your Apple Developer Team ID
OUTPUT_PATH=$3           # Output path for exportOptions.plist
# Check if all arguments are provided
if [ -z "$DISTRIBUTION_METHOD" ] || [ -z "$TEAM_ID" ] || [ -z "$OUTPUT_PATH" ]; then
    echo "Usage: $0 <distribution-method> <team-id> <output-path>"
    echo "Example: $0 app-store YOUR_TEAM_ID /path/to/exportOptions.plist"
    exit 1
fi

# Create exportOptions.plist
create_export_options_plist $DISTRIBUTION_METHOD $TEAM_ID $OUTPUT_PATH 

