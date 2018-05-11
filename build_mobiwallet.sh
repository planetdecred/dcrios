#!/bin/bash
git submodule init
git submodule update --checkout
cd mobilewallet/pkg
mkdir bin
export GOPATH=$(pwd)
export PATH=$PATH:$GOPATH/bin
cd src/mobilewallet
dep ensure -v
go get golang.org/x/mobile/cmd/gomobile
gomobile init
gomobile bind -target=ios
mkdir ../../../debug
mkdir ../../../release
cp -R Mobilewallet.framework ../../../debug
gomobile bind -target=ios/arm64
cp -R Mobilewallet.framework ../../../release
