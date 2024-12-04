# EmbeddedXCTest

This package provides a subclass of XCTestCase that can be used to run tests embedded into another run loop.

You specialise the class with something that implements the `TestHost` protocol.

When the tests run, the host will be instantiated and called with a closure
that it can use to actually run the tests.

The specific example that inspired this is SwiftGodot, where we want to be able to set up the Godot engine,
and then run some tests it has been initialised.

This is complicated using XCTest as there is no way to replace its main loop or to do setup work before
the first tests run.

This package allows you do create a simple host class that looks something like this:

```swift
struct GodotHost {
  func runEmbeddedTests(_ testRunner: () -> Int) {
    var failures = 0
    GodotEngine.init()
    GodotEngine.run {
      failures = testRunner()
      GodotEngine.shutdown()
    }
    if failures > 0 {
      exit(Int32(failures))
    }
  }
}
```

You can then use this in a test case like this:

```swift
class MyTestCase: EmbeddedXCTest<GodotHost> {
  func testSomething() {
    // this test will be run in the Godot engine
  }

  func testAnotherThing() {
    // this test will be run in the Godot engine
  }
}
```