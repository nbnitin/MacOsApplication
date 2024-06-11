#!/bin/bash

# Set your APNs credentials
KEY_ID="BBZK58U6QB"
TEAM_ID="U6YJ98JZZ5"
BUNDLE_ID="com.daxko.coreservices.internal"
KEY_PATH="./AuthKey_BBZK58U6QB.p8"

# Device token of the target device
DEVICE_TOKEN="e540b465c1ced30553543d986233b54675544de150774e16ac7d2c030993fd5c"

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

