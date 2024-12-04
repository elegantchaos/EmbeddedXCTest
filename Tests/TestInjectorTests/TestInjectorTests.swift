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
  var injectedSuite: XCTestSuite?
  var failures = 0
  var isInitialised = false
  var isRunning = false
  var _log: [String] = []

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

  func testCase(
    _ testCase: XCTestCase, didFailWithDescription description: String, inFile filePath: String?,
    atLine lineNumber: Int
  ) {
    failures += 1
    log("\(testCase) failed \(description) at \(filePath!):\(lineNumber)")
  }

  func testSuiteWillStart(_ testSuite: XCTestSuite) {
    log("testSuiteWillStart \(testSuite)")
  }

  func registerSuite(_ suite: XCTestSuite) {
    // if injectedSuite == nil {
    //   let def = XCTestSuite.default
    //   injectedSuite = XCTestSuite(name: "All Injected")
    //   def.addTest(injectedSuite!)
    //   for test in def.tests {
    //     print("def test \(test)")
    //   }
    // }

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

    // if (testSuite.name == "All Tests") || (testSuite.name == "Selected Tests") {
    //   log("finished running all tests")
    //   let all = XCTestSuite(name: "All Injected Tests")
    //   for suite in injectedSuites {
    //     all.addTest(suite)
    //   }
    //   testSuite.addTest(all)
    // }
  }

  func testCaseWillStart(_ testCase: XCTestCase) {
    log("running injected \(testCase)")
  }

  func testCaseDidFinish(_ testCase: XCTestCase) {
    log("finished running injected \(testCase)")
  }

  func testBundleDidFinish(_ testBundle: Bundle) {
    log("Got \(injectedSuites.count) injected suites")
    let all = XCTestSuite(name: "All Injected Tests")
    for suite in injectedSuites {
      all.addTest(suite)
    }

    isRunning = true
    // let r = XCTestSuiteRun(test: all)
    // r.start()
    // all.perform(r)
    all.run()
    isRunning = false

    log("testBundleDidFinish \(testBundle)")

    if failures > 0 {
      exit(Int32(failures))
    }
    // print(_log.joined(separator: "\n"))
  }
}
