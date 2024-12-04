// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 04/12/2024.
//  All code (c) 2024 - present day, Sam Deane.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
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

class InjectedTestCase<T: TestInjector>: XCTestCase {
  //   static override func setUp() {
  //     super.setUp()
  //   }
  //   override func invokeTest() {
  //     if T.isRunning {
  //       super.invokeTest()
  //     }
  //   }

  override func run() {
    T.installHooks()
    if T.instance.isRunning {
      //   print("running \(self)")
      super.run()
      //   print("finished \(self)")
    }
  }
}

protocol TestInjector {
  var isRunning: Bool { get set }
  static var instance: TestInjector { get }
  static func installHooks()
}

class InjectionObserver: NSObject, XCTestObservation, TestInjector {
  nonisolated(unsafe) static var _instance: InjectionObserver?

  static var instance: TestInjector { _instance! }

  static func installHooks() {
    if _instance == nil {
      let observer = InjectionObserver()
      _instance = observer
      XCTestObservationCenter.shared.addTestObserver(observer)
    }
  }

  var injectedSuites: [XCTestSuite] = []
  var isInitialised = false
  var isRunning = false

  func testBundleWillStart(_ testBundle: Bundle) {
    print("testBundleWillStart \(testBundle)")
  }

  func testSuite(_ testSuite: XCTestSuite, didRecord issue: XCTIssue) {
    print("\(testSuite) recorded \(issue)")
  }

  func testSuite(_ testSuite: XCTestSuite, didRecord expectedFailure: XCTExpectedFailure) {
    print("\(testSuite) recorded \(expectedFailure)")
  }

  func testSuiteWillStart(_ testSuite: XCTestSuite) {
    print("testSuiteWillStart \(testSuite)")
    if !isRunning {
      print("added injected suite to \(testSuite)")
      let suite = XCTestSuite(name: "Injected-\(testSuite.name)")
      for test in testSuite.tests {
        suite.addTest(test)
      }
      injectedSuites.append(suite)
    }
  }

  func testSuiteDidFinish(_ testSuite: XCTestSuite) {
    print("testSuiteDidFinish \(testSuite)")
  }

  func testCaseWillStart(_ testCase: XCTestCase) {
    print("running injected \(testCase)")
  }

  func testCaseDidFinish(_ testCase: XCTestCase) {
    print("finished running injected \(testCase)")
  }

  func testBundleDidFinish(_ testBundle: Bundle) {
    isRunning = true
    for suite in injectedSuites {
      suite.run()
    }
    isRunning = false
    print("testBundleDidFinish \(testBundle)")
  }
}
