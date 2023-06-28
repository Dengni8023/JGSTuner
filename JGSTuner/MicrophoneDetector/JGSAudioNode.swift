//
//  JGSAudioNode.swift
//  JGSTuner
//
//  Created by 梅继高 on 2023/6/28.
//  Copyright © 2023 MeiJigao. All rights reserved.
//

import AVFoundation

/// Node in an audio graph
internal protocol JGSAudioNode: AnyObject {
    /// Nodes providing audio input to this node.
    var connections: [JGSAudioNode] { get }
    /// Internal AVAudioEngine node.
    var audioNode: AVAudioNode { get }
}

internal extension AVAudioFormat {
    static var JGSTunerStereo: AVAudioFormat {
        AVAudioFormat(standardFormatWithSampleRate: 44_100 /* 44100 */, channels: 2) ?? AVAudioFormat()
    }
}

internal extension AVAudioNode {
    
    /// Make a connection without breaking other connections.
    func jg_connect(input: AVAudioNode, bus: Int) {
        guard let engine = engine else { return }

        var points = engine.outputConnectionPoints(for: input, outputBus: 0)
        if points.contains(where: { $0.node === self && $0.bus == bus }) {
            return
        }

        points.append(AVAudioConnectionPoint(node: self, bus: bus))
        engine.connect(input, to: points, fromBus: 0, format: .JGSTunerStereo)
    }
}

internal extension AVAudioMixerNode {
    
    /// Make a connection without breaking other connections.
    func jg_connectMixer(input: AVAudioNode) {
        guard let engine = engine else { return }

        var points = engine.outputConnectionPoints(for: input, outputBus: 0)
        if points.contains(where: { $0.node === self }) {
            return
        }
        
        points.append(AVAudioConnectionPoint(node: self, bus: nextAvailableInputBus))
        engine.connect(input, to: points, fromBus: 0, format: .JGSTunerStereo)
    }
}
