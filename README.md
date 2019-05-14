# dcrios - Decred Mobile Wallet

A Decred Mobile Wallet for iOS that runs on top of [dcrwallet](https://github.com/decred/dcrwallet).

## Requirements

IOS 10.3 or above.

## Build Instructions
Clone this repo, install and setup the following software tools. The versions in brackets are not definite, other versions may work. This process has been confirmed working with the versions specified.

### Requirements
- [Xcode](https://developer.apple.com/xcode/). _(Version 10.1)_.
- [Go](http://golang.org/doc/install). _(Version 1.12.1 tested, 1.11 should work too)_.
  - Ensure your `$GOPATH` environment variable is set 
  - Ensure that your `$GOPATH/bin` is added to your `$PATH` environment variable.
  - Ensure that your `GOBIN=$GOPATH/bin` is added to your `$PATH` environment variable.

	in the bash shell, it will look similar to this in your ```~/.bash_profile``` or equiv

    ```bash
    export GOPATH=$HOME/go
    export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
    export GOBIN=$GOPATH/bin
    ```

- [Gomobile](https://github.com/golang/go/wiki/Mobile#tools) _(latest version)_.
  - Run `go get golang.org/x/mobile/cmd/gomobile`  to ensure you're using the latest version of `gomobile`.
  - Run `gomobile init` afterwards to setup `gomobile`.

### Building/running the app
- Run `pod install` to download project dependencies.
- Run `build_wallet_framework.sh` to generate `dcrlibwallet.framework` using a preset revision/commit of [dcrlibwallet](https://github.com/raedahgroup/dcrlibwallet). The generated `Dcrlibwallet.framework` binary will be placed in `./libs` sub-directory.
- Open `decred_wallet.xcworkspace` with Xcode and build/run.
