#!/bin/bash

set -ev

if [[ "$TRAVIS_OS_NAME" == "linux" ]]; then
    DIR="$(pwd)"
    cd ..
    export SWIFT_VERSION=swift-4.1.1-RELEASE
    export UBUNTU_VERSION=ubuntu16.04
    wget https://swift.org/builds/swift-4.1.1-release/ubuntu1604/${SWIFT_VERSION}/${SWIFT_VERSION}-${UBUNTU_VERSION}.tar.gz
    tar xzf ${SWIFT_VERSION}-${UBUNTU_VERSION}.tar.gz
    export PATH="${PWD}/${SWIFT_VERSION}-${UBUNTU_VERSION}/usr/bin:${PATH}"
    cd "$DIR"
fi
