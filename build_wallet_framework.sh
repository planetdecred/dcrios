#!/bin/bash
export LIB_DIR=$(pwd)/libs
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
	# update with the appropriate tag/commit hash to checkout 
	git checkout v1.0.0
	echo "done cloning dcrlibwallet"
}

updateDcrlibwallet() {
	cd $DCRLIBWALLET_GIT_DIR
	git fetch
	# update with the appropriate tag/commit hash to checkout 
	git checkout v1.0.0
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
	rm -rf $LIB_DIR
	mkdir $LIB_DIR
	cp -R -f Dcrlibwallet.framework $LIB_DIR/Dcrlibwallet.framework
	echo "done"
}

main
