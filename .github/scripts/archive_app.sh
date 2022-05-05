#!/bin/bash

set -eo pipefail

xcodebuild -workspace Decred\ Wallet.xcworkspace \
            -scheme Decred\ Wallet\ Testnet \
            -sdk iphoneos \
            -configuration Testnet\ Release \
            -archivePath $PWD/build/Decred\ Wallet.xcarchive \
            -allowProvisioningUpdates \
            CODE_SIGN_IDENTITY="iPhone Distribution" \
            PROVISIONING_PROFILE="b6b99236-cee8-4bab-abc8-1735c701853a" \
            CODE_SIGN_STYLE="Manual" \
            DEVELOPMENT_TEAM="UX9L95U548" \
            clean archive | xcpretty
