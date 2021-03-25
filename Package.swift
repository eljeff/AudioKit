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
            exclude: ["AudioKitCore/Sampler/README.md",
                    "AudioKitCore/Common/AHDSHREnvelope.hpp",
                    "Devoloop/include/FFTReal/FFTRealFixLen.hpp",
                    "AudioKitCore/Common/README.md",
                    "AudioKitCore/Sampler/SampleBuffer.hpp",
                    "Devoloop/include/FFTReal/FFTRealUseTrigo.hpp",
                    "AudioKitCore/Common/EnsembleOscillator.hpp",
                    "AudioKitCore/Common/SynthVoice.hpp",
                    "AudioKitCore/Sampler/Wavpack/license.txt",
                    "AudioKitCore/Common/WaveStack.hpp",
                    "AudioKitCore/Common/FunctionTable.hpp",
                    "AudioKitCore/Common/SustainPedalLogic.hpp",
                    "Devoloop/include/FFTReal/FFTReal.hpp",
                    "AudioKitCore/Modulated Delay/AdjustableDelayLine.hpp",
                    "Devoloop/include/OscSinCos.hpp",
                    "Nodes/Effects/Distortion/DiodeClipper.hpp",
                    "Devoloop/include/FFTReal/FFTRealPassDirect.hpp",
                    "Devoloop/include/FFTReal/FFTRealSelect.hpp",
                    "AudioKitCore/README.md",
                    "AudioKitCore/Sampler/SampleOscillator.hpp",
                    "Nodes/Generators/Physical Models/STKInstrumentDSP.hpp",
                    "AudioKitCore/Common/AudioKitCore.hpp",
                    "Devoloop/include/Array.hpp",
                    "Devoloop/include/FFTReal/FFTRealPassInverse.hpp",
                    "AudioKitCore/Common/EnvelopeGeneratorBase.hpp",
                    "Devoloop/include/DynArray.hpp",
                    "AudioKitCore/Common/ADSREnvelope.hpp",
                    "AudioKitCore/Common/Envelope.hpp",
                    "AudioKitCore/Common/ResonantLowPassFilter.hpp",
                    "Nodes/Effects/Distortion/DiodeClipper.soul",
                    "AudioKitCore/Modulated Delay/README.md",
                    "CoreAudio/SoulDSP.hpp",
                    "AudioKitCore/Common/DrawbarsOscillator.hpp",
                    "AudioKitCore/Common/MultiStageFilter.hpp",
                    "AudioKitCore/Common/LinearRamper.hpp",
                    "AudioKitCore/Modulated Delay/StereoDelay.hpp",
                    "AudioKitCore/Sampler/SamplerVoice.hpp"],
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
            dependencies: ["AudioKit"],
            exclude: ["Resources/PinkNoise.wav",
                      "Resources/drumloop.wav",
                      "Resources/sinechirp.wav",
                      "Resources/12345.wav"]),
        .testTarget(
            name: "CAudioKitTests",
            dependencies: ["CAudioKit"])
    ],
    cxxLanguageStandard: .cxx14
)
