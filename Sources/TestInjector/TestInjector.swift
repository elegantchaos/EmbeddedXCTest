// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 04/12/2024.
//  All code (c) 2024 - present day, Sam Deane.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import XCTest

open class InjectedTestCase<T: TestInjector>: XCTestCase {
  public override static func setUp() {
    T.installHooks()
    T.instance.log("setup \(self)")
    super.setUp()
  }

  open override func run() {
    if T.instance.isRunning {
      T.instance.log("running \(self)")
      super.run()
      T.instance.log("finished \(self)")
    } else {
      T.instance.log("skipped \(self)")
    }
  }
}

public protocol TestInjector {
  var isRunning: Bool { get set }
  func log(_ message: String)
  static var instance: TestInjector { get }
  static func installHooks()
}

public class InjectionObserver: NSObject, XCTestObservation, TestInjector {
  nonisolated(unsafe) static var _instance: InjectionObserver?

  public static var instance: TestInjector { _instance! }

  public static func installHooks() {
    if _instance == nil {
      let observer = InjectionObserver()
      _instance = observer
      XCTestObservationCenter.shared.addTestObserver(observer)
    }
  }

  var injectedSuites: [XCTestSuite] = []
  let injectedSuite = XCTestSuite(name: "Injected Tests")
  var failures: [(XCTestCase, String, String?, Int)] = []
  var isInitialised = false
  public var isRunning = false
  var _log: [String] = []

  public func log(_ message: String) {
    _log.append(message)
  }

  public func testBundleWillStart(_ testBundle: Bundle) {
    log("testBundleWillStart \(testBundle)")
  }

  public func testSuite(_ testSuite: XCTestSuite, didRecord issue: XCTIssue) {
    log("\(testSuite) recorded \(issue)")
  }

  public func testSuite(_ testSuite: XCTestSuite, didRecord expectedFailure: XCTExpectedFailure) {
    log("\(testSuite) recorded \(expectedFailure)")
  }

  public func testCase(
    _ testCase: XCTestCase, didFailWithDescription description: String, inFile filePath: String?,
    atLine lineNumber: Int
  ) {
    failures.append((testCase, description, filePath, lineNumber))
  }

  public func testSuiteWillStart(_ testSuite: XCTestSuite) {
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
      injectedSuite.addTest(injected)
      log("added injected suite \(injected.name)")
    }
  }

  public func testSuiteDidFinish(_ testSuite: XCTestSuite) {
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

  public func testCaseWillStart(_ testCase: XCTestCase) {
    log("running injected \(testCase)")
  }

  public func testCaseDidFinish(_ testCase: XCTestCase) {
    log("finished running injected \(testCase)")
  }

  public func testBundleDidFinish(_ testBundle: Bundle) {
    print(
      """

      ----------------------------------------------------------
      Running injected tests
      ----------------------------------------------------------

      """)

    isRunning = true
    injectedSuite.run()
    isRunning = false

    log("testBundleDidFinish \(testBundle)")

    print(
      """

      ----------------------------------------------------------

      Finished running injected tests with \(failures.count) failures.

      """)

    if failures.count > 0 {
      exit(Int32(failures.count))
    }
  }
}
