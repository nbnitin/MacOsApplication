#!/bin/bash

# Set your APNs credentials
KEY_ID=""
TEAM_ID=""
BUNDLE_ID=""
KEY_PATH=""

# Device token of the target device
DEVICE_TOKEN=""

# Generate the JWT token
JWT=$(openssl ec -in "$KEY_PATH" -outform DER | openssl dgst -sha256 -binary | openssl enc -base64)

# APNs endpoint
APNS_URL="https://api.development.push.apple.com/3/device/$DEVICE_TOKEN"

# Your payload
PAYLOAD='{"aps":{"alert":"Test notification"}}'

# Send the notification using curl
curl -v -X POST "$APNS_URL" \
  --header "Authorization: Bearer $JWT" \
  --header "apns-topic: $BUNDLE_ID" \
  --header "apns-push-type: alert" \
  --data "$PAYLOAD"

