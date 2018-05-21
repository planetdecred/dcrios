#!/bin/bash
git submodule init
git submodule update --checkout
cd wallet/pkg
mkdir bin
unset GOROOT
export GOPATH=$(pwd)
export PATH=$PATH:$GOPATH/bin
cd src/mobilewallet
dep ensure -v
go get golang.org/x/mobile/cmd/gomobile
gomobile init
gomobile bind -target=ios
rm -rf ../../../debug
rm -rf ../../../release
mkdir ../../../debug
mkdir ../../../release
cp -R Wallet.framework ../../../debug
gomobile bind -target=ios/arm64
cp -R Wallet.framework ../../../release
