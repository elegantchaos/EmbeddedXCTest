// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 04/12/24.
//  All code (c) 2024 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public protocol TestHost {
  var isRunning: Bool { get set }
  func log(_ message: String)
  static var instance: TestHost { get }
  static func installHooks()
}

open class SimpleTestHost: InjectionObserver {
  public override func runEmbeddedTests() -> Int {
    let failures = super.runEmbeddedTests()
    if failures > 0 {
      exit(Int32(failures))
    }
    return failures
  }
}
