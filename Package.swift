// swift-tools-version:6.0

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 04/12/2024.
//  All code (c) 2024 - present day, Sam Deane.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import PackageDescription

var dependencies: [Package.Dependency] = []

var plugins: [Target.PluginUsage] = []

if ProcessInfo.processInfo.environment["RESOLVE_ACTION_PLUGINS"] != nil {
  // Optional support for the ActionBuilder plugin.
  dependencies.append(contentsOf: [
    .package(url: "https://github.com/elegantchaos/ActionBuilderPlugin.git", from: "2.0.0")
  ])
  plugins.append(.plugin(name: "ActionBuilderPlugin", package: "ActionBuilderPlugin"))
}

let package = Package(
  name: "EmbeddedXCTest",

  platforms: [
    .macOS(.v12), .macCatalyst(.v15), .iOS(.v15), .tvOS(.v15), .watchOS(.v8),
  ],

  products: [
    .library(
      name: "EmbeddedXCTest",
      targets: ["EmbeddedXCTest"]
    )
  ],

  dependencies: dependencies,

  targets: [
    .target(
      name: "EmbeddedXCTest",
      dependencies: [],
      plugins: plugins
    ),

    .testTarget(
      name: "EmbeddedXCTestTests",
      dependencies: [
        "EmbeddedXCTest"
      ]
    ),

    .testTarget(
      name: "MoreInjectorTests",
      dependencies: [
        "EmbeddedXCTest"
      ]
    ),
  ]
)
