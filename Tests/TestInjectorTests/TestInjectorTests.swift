// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 04/12/2024.
//  All code (c) 2024 - present day, Sam Deane.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import XCTest

class SomeTests: InjectedTestCase<InjectionObserver> {
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
  override static func setUp() {
    T.installHooks()
    T.instance.log("setup \(self)")
    super.setUp()
  }

  override func run() {
    if T.instance.isRunning {
      T.instance.log("running \(self)")
      super.run()
      T.instance.log("finished \(self)")
    } else {
      T.instance.log("skipped \(self)")
    }
  }
}

protocol TestInjector {
  var isRunning: Bool { get set }
  func log(_ message: String)
  static var instance: TestInjector { get }
  static func installHooks()
  func registerSuite(_ suite: XCTestSuite)
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
  var _log: [String] = []
  var outerSuite: XCTestSuite?

  func log(_ message: String) {
    _log.append(message)
  }

  func testBundleWillStart(_ testBundle: Bundle) {
    log("testBundleWillStart \(testBundle)")
  }

  func testSuite(_ testSuite: XCTestSuite, didRecord issue: XCTIssue) {
    log("\(testSuite) recorded \(issue)")
  }

  func testSuite(_ testSuite: XCTestSuite, didRecord expectedFailure: XCTExpectedFailure) {
    log("\(testSuite) recorded \(expectedFailure)")
  }

  func testSuiteWillStart(_ testSuite: XCTestSuite) {
    log("testSuiteWillStart \(testSuite)")
  }

  func registerSuite(_ suite: XCTestSuite) {
    if !isRunning {
      let injected = XCTestSuite(name: "Injected-\(suite.name)")
      for test in suite.tests {
        injected.addTest(test)
      }
      injectedSuites.append(injected)
      log("added injected suite \(injected.name)")
    }
  }

  func testSuiteDidFinish(_ testSuite: XCTestSuite) {
    log("testSuiteDidFinish \(testSuite) \(testSuite.className)")

    if testSuite.className == "XCTestCaseSuite" {
      registerSuite(testSuite)
    }
  }

  func testCaseWillStart(_ testCase: XCTestCase) {
    log("running injected \(testCase)")
  }

  func testCaseDidFinish(_ testCase: XCTestCase) {
    log("finished running injected \(testCase)")
  }

  func testBundleDidFinish(_ testBundle: Bundle) {
    if let outer = outerSuite {
    }
    isRunning = true
    log("Got \(injectedSuites.count) injected suites")
    for suite in injectedSuites {
      suite.run()
      //   let run = XCTestSuiteRun(test: suite)
      //   run.start()

      //   run.executionCount
    }
    isRunning = false
    log("testBundleDidFinish \(testBundle)")
    print(_log.joined(separator: "\n"))
  }
}
