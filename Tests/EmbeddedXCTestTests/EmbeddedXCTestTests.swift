// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 04/12/2024.
//  All code (c) 2024 - present day, Sam Deane.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import EmbeddedXCTest
import Foundation
import XCTest

class SomeTests: EmbeddedTestCase<SimpleTestHost> {
  nonisolated(unsafe) static var didSetup = false

  override class func setUp() {
    didSetup = true
    super.setUp()
  }

  func testInjecting() {
    print("hello from \(self)")
    XCTAssertTrue(Self.didSetup)
  }

  func testInjecting2() {
    print("hello from \(self)")
    XCTAssertTrue(Self.didSetup)
  }

  func testInjecting3() {
    print("hello from \(self)")
    XCTAssertTrue(Self.didSetup)
  }
}

class SomeMoreTests: EmbeddedTestCase<SimpleTestHost> {
  func testInjecting() {
    XCTFail("hello from \(self)")
  }

  func testInjecting2() {
    XCTFail("hello from \(self)")
  }

  func testInjecting3() {
    XCTFail("hello from \(self)")
  }
}

class NormalTests: XCTestCase {
  nonisolated(unsafe) static var runCount = 0
  func testNormalTest() {
    Self.runCount += 1
    XCTAssertTrue(Self.runCount == 1)
  }
}
