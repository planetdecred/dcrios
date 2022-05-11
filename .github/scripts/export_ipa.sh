#!/bin/bash

set -eo pipefail

xcodebuild -archivePath $PWD/build/Decred\ Wallet.xcarchive \
            -exportOptionsPlist Decred\ Wallet/exportOptions.plist \
            -exportPath $PWD/build \
            -allowProvisioningUpdates \
            -exportArchive | xcpretty
