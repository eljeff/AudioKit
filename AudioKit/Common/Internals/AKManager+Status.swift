//
//  AudioKit+Status.swift
//  AudioKit
//
//  Created by Jeff Cooper on 4/19/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Foundation
import AudioToolbox

extension AKManager {

    // MARK: Global audio format (44.1K, Stereo)

    /// Format of AudioKit Nodes
    @available(*, deprecated, renamed: "AKSettings.audioFormat")
    @objc public var format: AVAudioFormat {
        return AKSettings.audioFormat
    }

    #if os(iOS)
    var isIAAConnected: Bool {
        #if !targetEnvironment(macCatalyst)
        do {
            let result: UInt32? = try engine.outputNode.audioUnit?.getValue(forProperty: kAudioUnitProperty_IsInterAppConnected)
            return result == 1
        } catch {
            AKLog("could not get IAA status: \(error)")
        }
        #endif
        return false
    }
    #endif
}
