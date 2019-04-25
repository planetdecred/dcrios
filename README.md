# dcrios - Decred Mobile Wallet

A Decred Mobile Wallet for iOS that runs on top of [dcrwallet](https://github.com/decred/dcrwallet).

## Requirements

IOS 10.3 or above.

## Build Instructions
[Xcode](https://developer.apple.com/xcode/) and [Dcrlibwallet](https://github.com/raedahgroup/dcrlibwallet) are required to build this project.

Clone this repo and run `build_wallet_framework.sh` to build Dcrlibwallet and add the generated library as a framework to the Xcode project (requires [go to be installed](http://golang.org/doc/install) with $GOPATH set and [Gomobile](https://github.com/golang/go/wiki/Mobile#tools) installed and initialized with `gomobile init`). Then open this project with Xcode and build.

It's important to have your generated `Dcrlibwallet.framework` binary in `./libs` directory for the project to build with Xcode.
