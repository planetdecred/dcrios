#!/bin/bash

set -eo pipefail

xcodebuild -workspace Decred\ Wallet.xcworkspace \
            -scheme Decred\ Wallet\ Testnet \
            -destination platform=iOS\ Simulator,OS=13.3,name=iPhone\ 11 \
            clean test | xcpretty
