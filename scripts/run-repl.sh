#!/bin/bash
if [[ "$OSTYPE" == "linux-gnu" ]]; then
    inc=-I/usr/lib/swift/clang/include
else
    inc=""
fi
bd=".build/release"
swift build -c release -Xswiftc -enable-testing \
    && swift ${inc} -I${bd} -L${bd} -lComplex
