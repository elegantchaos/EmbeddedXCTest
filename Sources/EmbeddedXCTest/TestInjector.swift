// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 04/12/2024.
//  All code (c) 2024 - present day, Sam Deane.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import XCTest

open class InjectionObserver: NSObject, XCTestObservation, TestHost {
  nonisolated(unsafe) static var _instance: InjectionObserver?

  public static var instance: TestHost { _instance! }

  public static func installHooks() {
    if _instance == nil {
      // turn off buffering on stdout so that we see the output immediately
      setbuf(__stdoutp, nil)

      let observer = InjectionObserver()
      _instance = observer
      XCTestObservationCenter.shared.addTestObserver(observer)
    }
  }

  func registerSuite(_ suite: XCTestSuite) {
    if !isRunning {
      let injected = XCTestSuite(name: "Embedded-\(suite.name)")
      for test in suite.tests {
        injected.addTest(test)
      }
      injectedSuite.addTest(injected)
      log("added injected suite \(injected.name)")
    }
  }
  let injectedSuite = XCTestSuite(name: "Embedded Tests")
  var failures: [(XCTestCase, String, String?, Int)] = []
  public var isRunning = false
  var _log: [String] = []

  public func log(_ message: String) {
    _log.append(message)
  }

  public func runEmbeddedTests() -> Int {
    print(
      """

      ----------------------------------------------------------
      Running injected tests
      ----------------------------------------------------------

      """)

    isRunning = true
    injectedSuite.run()
    isRunning = false

    print(
      """

      ----------------------------------------------------------

      Finished running injected tests with \(failures.count) failures.

      """)

    return failures.count
  }

  public func testCase(
    _ test: XCTestCase, didFailWithDescription description: String, inFile path: String?,
    atLine line: Int
  ) {
    failures.append((test, description, path, line))
  }

  public func testSuiteDidFinish(_ testSuite: XCTestSuite) {
    if testSuite.className == "XCTestCaseSuite" {
      registerSuite(testSuite)
    }
  }

  public func testBundleDidFinish(_ testBundle: Bundle) {
    _ = runEmbeddedTests()
  }
}
