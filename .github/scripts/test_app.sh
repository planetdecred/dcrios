#!/bin/bash

set -eo pipefail

xcodebuild -workspace Decred\ Wallet.xcworkspace \
            -scheme Decred\ Wallet\ Testnet \
            -destination platform=iOS\ Simulator,OS=15.0,name=iPhone\ 12\ Pro\ Max \
            clean test | xcpretty
