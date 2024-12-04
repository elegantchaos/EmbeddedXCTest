# EmbeddedXCTest

This package provides a subclass of XCTestCase that can be used to run tests embedded into another run loop.

You specialise the class with something that implements the `TestHost` protocol.

When the tests run, the host will be instantiated and called with a closure
that it can use to actually run the tests.

The specific example that inspired this is SwiftGodot, where we want to be able to set up the Godot engine,
and then run some tests it has been initialised.

This is complicated using XCTest as there is no way to replace its main loop or to do setup work before
the first tests run.

This package allows you do create a simple host class that looks something like this psuedo-code:

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

## How?

The basic approach is that we let the normal XCTest shell run all the tests normally, 
but suppress as much output as we can from them during this initial run.

As early as we can, we register a custom observer for the tests. This is registered 
after at least one test has started running, but before any of the suites have 
finished  running, so we can use the `testSuiteDidFinish` callback to take a copy
of each suite for later. We add this copy to our own master suite, that we build
up slowly.

When we get the `testBundleDidFinish` callback, we know that all tests for the bundle
are done. We can then call into our custom host class to ask it to run the tests again. 
The host can do whatever set up it needs to do, and then call a closure we supplied, 
which will do the actual running of the master suite of tests we built up.

Before we do this second run, we turn off our suppression of tests, and so the
tests now run properly and produce output.

However, because the normal test shell thinks it has already finished, test failures
don't result in the shell exiting with a non-zero status. 

To work around this, we also intercept the `testCase:didFailWithDescription` callback,
to keep a record of failures, and we return this as the result of the closure
we gave the host.

Once the closure returns control to the host, it can do any cleanup it wants to do
and can then use the failure count it got back to call `exit()` if there were failures.

This isn't ideal, as it's a fast exit from the XCTest shell, but it's the only way
I've found so far to get a non-zero status code back to the calling process.
