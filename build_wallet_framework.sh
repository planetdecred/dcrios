#!/bin/bash
cd wallet/pkg
mkdir bin
unset GOROOT
export GOPATH=$(pwd)
export PATH=$PATH:$GOPATH/bin
mkdir -p go/src/github.com/raedahgroup/mobilewallet
cd src/mobilewallet
dep ensure -v
go get golang.org/x/mobile/cmd/gomobile
gomobile init

rm -rf ../../../debug
rm -rf ../../../release
mkdir ../../../debug
mkdir ../../../release

export GOOS=darwin
export GOARCH=arm
export GOARM=7
gomobile bind -target=ios
cp -R -f Mobilewallet.framework ../../../debug/Mobilewallet.framework
cp -R -f Mobilewallet.framework ../../../release/Mobilewallet.framework
lipo -remove i386 -remove x86_64 Mobilewallet.framework/Versions/Current/Mobilewallet -output Mobilewallet
mv Mobilewallet ../../../release/Mobilewallet.framework/Versions/Current/Mobilewallet
