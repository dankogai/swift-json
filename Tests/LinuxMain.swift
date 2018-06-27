import XCTest

import JSONTests

var tests = [XCTestCaseEntry]()
tests += JSONTests.allTests()
XCTMain(tests)