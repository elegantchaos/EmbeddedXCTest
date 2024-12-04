// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 04/12/24.
//  All code (c) 2024 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest

open class EmbeddedTestCase<T: TestHost>: XCTestCase {

  open override var testRunClass: AnyClass? {
    T.instance.isRunning ? SilentTestRun.self : super.testRunClass
  }

  public override static func setUp() {
    T.installHooks()
    super.setUp()
  }

  open override func run() {
    if T.instance.isRunning {
      super.run()
    }
  }
}
