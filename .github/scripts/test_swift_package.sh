#!/bin/bash

set -eo pipefail

cd Decred\ Wallet; swift test --parallel; cd ..
