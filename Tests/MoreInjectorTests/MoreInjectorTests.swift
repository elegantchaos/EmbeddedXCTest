// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 04/12/2024.
//  All code (c) 2024 - present day, Sam Deane.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import EmbeddedXCTest
import Foundation
import XCTest

class MoreTests: EmbeddedTestCase<SimpleTestHost> {
  func testInjecting() {
    print("hello from \(self)")
  }

  func testInjecting2() {
    print("hello from \(self)")
  }

  func testInjecting3() {
    print("hello from \(self)")
  }
}

class YetMoreTests: EmbeddedTestCase<SimpleTestHost> {
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
