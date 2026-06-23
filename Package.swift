// swift-tools-version:5.9
import PackageDescription

let package = Package(
  name: "Almanac",
  defaultLocalization: "tr",
  platforms: [
    .iOS(.v17),
  ],
  products: [
    .library(name: "Almanac", targets: ["Almanac"]),
  ],
  dependencies: [
    .package(url: "https://github.com/airbnb/HorizonCalendar.git", from: "2.0.0"),
    .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.17.0"),
  ],
  targets: [
    .target(
      name: "Almanac",
      dependencies: ["HorizonCalendar"],
      resources: [.process("Resources")]),
    .testTarget(
      name: "AlmanacTests",
      dependencies: [
        "Almanac",
        .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
      ]),
  ])
