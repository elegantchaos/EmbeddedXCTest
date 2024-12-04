// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 04/12/2024.
//  All code (c) 2024 - present day, Sam Deane.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import TestInjector
import XCTest

class SomeTests: InjectedTestCase<InjectionObserver> {
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

class MoreTests: InjectedTestCase<InjectionObserver> {
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
