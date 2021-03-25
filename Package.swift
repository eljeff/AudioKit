// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AudioKit",
    platforms: [
        .macOS(.v10_14), .iOS(.v11), .tvOS(.v11)
    ],
    products: [
        .library(
            name: "AudioKit",
            type: .static,
            targets: ["AudioKit"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        //.package(url: "https://github.com/apple/swift-atomics", from: "0.0.2")
    ],
    targets: [
        .target(name: "STK",
                exclude: ["rawwaves", "LICENSE"],
                publicHeadersPath: "include"),
        .target(name: "soundpipe",
                exclude: ["README.md",
                          "lib/kissfft/COPYING",
                          "lib/kissfft/README",
                          "lib/inih/LICENSE.txt"],
                publicHeadersPath: "include",
                cSettings: [
                    .headerSearchPath("lib/kissfft"),
                    .headerSearchPath("lib/inih"),
                    .headerSearchPath("Sources/soundpipe/lib/inih"),
                    .headerSearchPath("modules"),
                    .headerSearchPath("external")
                ]),
        .target(
            name: "sporth",
            dependencies: ["soundpipe"],
            exclude: ["README.md"],
            publicHeadersPath: "include"),
        .target(
            name: "CAudioKit",
            dependencies: ["STK", "soundpipe", "sporth"],
            exclude: ["AudioKitCore/Sampler/README.md"],
            publicHeadersPath: "include",
            cxxSettings: [
                .headerSearchPath("CoreAudio"),
                .headerSearchPath("AudioKitCore/Common"),
                .headerSearchPath("Devoloop/include"),
                .headerSearchPath("include"),
                .headerSearchPath(".")
            ]
        ),
        .target(
            name: "AudioKit",
            dependencies: ["CAudioKit"],
            exclude: ["Nodes/Playback/Samplers/PreparingSampleSets.md",
                      "Nodes/Playback/Samplers/Samplers.md",
                      "Nodes/README.md",
                      "Nodes/Generators/Physical Models/README.md",
                      "Nodes/Playback/Samplers/Sampler/Sampler.md",
                      "Nodes/Playback/Samplers/Apple Sampler/AppleSamplerNotes.md",
                      "Nodes/Effects/Modulation/README.md",
                      "Nodes/Effects/Guitar Processors/README.md",
                      "Nodes/Playback/Samplers/Sampler/README.md",
                      "Operations/README.md",
                      "Internals/README.md",
                      "Nodes/Effects/Modulation/ModulatedDelayEffects.md",
                      "MIDI/README.md",
                      "Nodes/Effects/Modulation/ModDelay.svg",
                      "Nodes/Effects/README.md",
                      "Nodes/Playback/Samplers/Apple Sampler/Skeleton.aupreset",
                      "Internals/Table/README.md",
                      "Analysis/README.md"]),
        .testTarget(
            name: "AudioKitTests",
            dependencies: ["AudioKit"]),
        .testTarget(
            name: "CAudioKitTests",
            dependencies: ["CAudioKit"])
    ],
    cxxLanguageStandard: .cxx14
)
