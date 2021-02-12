// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

extension AVAudioNode {
    /// Disconnect and manage engine connections
    public func disconnect(input: AVAudioNode) {
        if let engine = engine {
            for bus in 0 ..< numberOfInputs {
                if let cp = engine.inputConnectionPoint(for: self, inputBus: bus) {
                    if cp.node === input {
                        engine.disconnectNodeInput(self, bus: bus)
                    }
                }
            }
        }
    }

    /// Make a connection without breaking other connections.
    public func connect(input: AVAudioNode, bus: Int, format: AVAudioFormat? = AKSettings.audioFormat) {
        if let engine = engine {
            var points = engine.outputConnectionPoints(for: input, outputBus: 0)
            if points.contains(where: { $0.node === self }) { return }
            points.append(AVAudioConnectionPoint(node: self, bus: bus))
            engine.connect(input, to: points, fromBus: 0, format: format)
        }
    }
}

/// AudioKit's wrapper for AVAudioEngine
public class AudioEngine {
    /// Internal AVAudioEngine
    public let avEngine = AVAudioEngine()

    // maximum number of frames the engine will be asked to render in any single render call
    let maximumFrameCount: AVAudioFrameCount = 1_024

    /// Main mixer at the end of the signal chain
    public private(set) var mainMixerNode: AKMixer?

    /// Input node mixer
    public class InputNode: AKMixer {
        var isNotConnected = true

        func connect(to engine: AudioEngine) {
            engine.avEngine.attach(avAudioNode)
            engine.avEngine.connect(engine.avEngine.inputNode, to: avAudioNode, format: nil)
        }
    }

    let _input = InputNode()

    /// Input for microphone or other device is created when this is accessed
    /// If adjusting AudioKit.AKSettings, do so before setting up the microphone.
    /// Setting the .defaultToSpeaker option in AudioKit.AKSettings.session.setCategory after setting up your mic
    /// can cause the AVAudioEngine to stop running.
    public var input: InputNode? {
        if #available(macOS 10.14, *) {
            guard Bundle.main.object(forInfoDictionaryKey: "NSMicrophoneUsageDescription") != nil else {
                AKLog("To use the microphone, you must include the NSMicrophoneUsageDescription in your Info.plist", type: .error)
                return nil
            }
        }
        if _input.isNotConnected {
            _input.connect(to: self)
            _input.isNotConnected = false
        }
        return _input
    }

    /// Empty initializer
    public init() {}

    /// Output node
    public var output: AKNode? {
        didSet {
            // AVAudioEngine doesn't allow the outputNode to be changed while the engine is running
            let wasRunning = avEngine.isRunning
            if wasRunning { stop() }

            // remove the exisiting node if it is present
            if let node = oldValue {
                mainMixerNode?.disconnectInput()
                node.detach()
                avEngine.outputNode.disconnect(input: node.avAudioNode)
            }

            // if non nil, set the main output now
            if let node = output {
                avEngine.attach(node.avAudioNode)

                // has the sample rate changed?
                if let currentSampleRate = mainMixerNode?.avAudioUnitOrNode.outputFormat(forBus: 0).sampleRate,
                    currentSampleRate != AKSettings.sampleRate {
                    AKLog("Sample Rate has changed, creating new mainMixerNode at", AKSettings.sampleRate)
                    removeEngineMixer()
                }

                // create the on demand mixer if needed
                createEngineMixer()
                mainMixerNode?.connect(input: node)
//                mainMixerNode?.makeAVConnections()
            }

            if wasRunning { try? start() }
        }
    }

    // simulate the AVAudioEngine.mainMixerNode, but create it ourselves to ensure the
    // correct sample rate is used from AKSettings.audioFormat
    private func createEngineMixer() {
        guard mainMixerNode == nil else { return }

        let mixer = AKMixer()
        avEngine.attach(mixer.avAudioNode)
        avEngine.connect(mixer.avAudioNode, to: avEngine.outputNode, format: AKSettings.audioFormat)
        mainMixerNode = mixer
    }

    private func removeEngineMixer() {
        guard let mixer = mainMixerNode else { return }
        avEngine.outputNode.disconnect(input: mixer.avAudioNode)
        //mixer.removeAllInputs()
        mixer.detach()
        mainMixerNode = nil
    }

    /// Start the engine
    public func start() throws {
        if output == nil {
            AKLog("🛑 Error: Attempt to start engine with no output.")
            return
        }
        try avEngine.start()
    }

    /// Stop the engine
    public func stop() {
        avEngine.stop()
    }

    /// Pause the engine
    public func pause() {
        avEngine.pause()
    }
}
