// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 04/12/2024.
//  All code (c) 2024 - present day, Sam Deane.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import XCTest

class TestInjectorTests: InjectedTestCase<ExampleInjector> {
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

class MoreTestInjectorTests: InjectedTestCase<ExampleInjector> {
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
  static override func setUp() {
    T.startSuite(self)
    super.setUp()
  }

  static override func tearDown() {
    super.tearDown()
    T.endSuite(self)
  }

  override func setUp() async throws {
    T.registerTest(self)
    try await super.setUp()
  }

  override func invokeTest() {
    if T.isRunning {
      super.invokeTest()
    }
  }
  //   override func run() {
  //     if T.isRunning {
  //       super.run()
  //     }
  //   }
}

protocol TestInjector {
  static var isRunning: Bool { get set }
  static var isInitialised: Bool { get set }
  static func startSuite(_ suite: XCTest.Type)
  static func endSuite(_ suite: XCTest.Type)
  static func registerTest(_ test: XCTest)
}

actor ExampleInjector: TestInjector {
  static var isRunning = false
  static var isInitialised = false

  static var currentSuite: XCTest.Type?
  static var currentTests: [XCTest] = []

  static func registerTest(_ test: XCTest) {
    currentTests.append(test)
  }

  static func startSuite(_ suite: XCTest.Type) {
    assert(currentSuite == nil)
    currentSuite = suite

    if !isInitialised {
      XCTestObservationCenter.shared.addTestObserver(InjectionObserver())
      isInitialised = true
    }
  }

  static func endSuite(_ suite: XCTest.Type) {
    assert(currentSuite == suite)
    print("emitting tests for \(suite)")
    for test in currentTests {
      print("emitting test \(test)")
    }
    currentSuite = nil
    currentTests = []

  }

}

class InjectionObserver: NSObject, XCTestObservation {
  var outerSuite: XCTestSuite?
  var injectedSuite: XCTestSuite?
  var injectionStack: [XCTestSuite] = []
  var runningInjected = false

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
    if outerSuite == nil {
      outerSuite = testSuite
      injectedSuite = XCTestSuite(name: "Injected Tests")
      injectionStack.append(injectedSuite!)
      outerSuite?.addTest(injectedSuite!)
    }

    if testSuite === injectedSuite {
      runningInjected = true
    }

    if !runningInjected {
      if let top = injectionStack.last {
        let newSuite = XCTestSuite(name: "Injected \(testSuite.name)")
        top.addTest(newSuite)
        injectionStack.append(newSuite)
      }
    }
  }

  func testSuiteDidFinish(_ testSuite: XCTestSuite) {
    if !injectionStack.isEmpty {
      injectionStack.removeLast()
    }
  }

  func testCaseWillStart(_ testCase: XCTestCase) {
    if runningInjected {
      print("testCaseWillStart \(testCase)")
    } else {
      if let top = injectionStack.last {
        let newCase = XCTestCase(invocation: testCase.invocation)
        // newCase.name = "Injected \(testCase.name)"
        top.addTest(newCase)
      }
    }
  }

  func testCaseDidFinish(_ testCase: XCTestCase) {
    if runningInjected {
      print("testCaseDidFinish \(testCase)")
    }
  }

  func testBundleDidFinish(_ testBundle: Bundle) {
    print("testBundleDidFinish \(testBundle)")
  }
}
