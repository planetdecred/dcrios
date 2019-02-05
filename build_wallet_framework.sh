#!/bin/bash
export DEBUG_LIB_DIR=$(pwd)/debug
export RELEASE_LIB_DIR=$(pwd)/release
export DCRLIBWALLET_GIT_DIR=$GOPATH/src/github.com/raedahgroup/dcrlibwallet

main() {
	if [ -e $DCRLIBWALLET_GIT_DIR ]
	then
		echo "dcrlibwallet git folder found, running git pull"
		updateDcrlibwallet;
	else
		echo "dcrlibwallet git folder does not exist, running git clone"
		cloneDcrlibwallet;
	fi

	echo "building dcrlibwallet"
	buildDcrlibwallet;

	echo "copying built binary"
	copyLibrary;
}

cloneDcrlibwallet() {
	rm -rf $DCRLIBWALLET_GIT_DIR
	mkdir -p $DCRLIBWALLET_GIT_DIR
	git clone https://github.com/raedahgroup/dcrlibwallet.git $DCRLIBWALLET_GIT_DIR
	echo "done cloning dcrlibwallet"
}

updateDcrlibwallet() {
	cd $DCRLIBWALLET_GIT_DIR
	git checkout master && git pull origin master
	echo "done updating dcrlibwallet"
}

buildDcrlibwallet() {
	cd $DCRLIBWALLET_GIT_DIR
	rm -rf Dcrlibwallet.framework/
	export GO111MODULE=on
	go mod download
	go mod vendor
	export GO111MODULE=off
	gomobile bind -target=ios
	echo "done building dcrlibwallet"
}

copyLibrary() {
	rm -rf $DEBUG_LIB_DIR
	rm -rf $RELEASE_LIB_DIR
	mkdir $DEBUG_LIB_DIR
	mkdir $RELEASE_LIB_DIR
	cp -R -f Dcrlibwallet.framework $DEBUG_LIB_DIR/Dcrlibwallet.framework
	cp -R -f Dcrlibwallet.framework $RELEASE_LIB_DIR/Dcrlibwallet.framework
	echo "done"
}

main
