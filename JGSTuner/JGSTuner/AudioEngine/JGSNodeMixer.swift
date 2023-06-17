//
//  JGSNodeMixer.swift
//  JGSTuner
//
//  Created by 梅继高 on 2023/6/15.
//

import AVFoundation

private extension JGSAudioNode {
    func makeConnections() {
        // Attached
        guard let engine = audioNode.engine else { return }
        
        for (bus, connection) in connections.enumerated() {
            if let srcEngine = connection.audioNode.engine, srcEngine != audioNode.engine {
                assertionFailure("Attempt to connect nodes from different engine.")
                return
            }
            
            engine.attach(connection.audioNode)
            
            // Mixers will decide which input bus to use.
            if let mixer = audioNode as? AVAudioMixerNode {
                mixer.jg_connectMixer(input: connection.audioNode)
            } else {
                audioNode.jg_connect(input: connection.audioNode, bus: bus)
            }
        }
    }
}

final class JGSNodeMixer: JGSAudioNode {
    private var inputs: [JGSAudioNode] = []
    /// Connected nodes
    var connections: [JGSAudioNode] { inputs }
    
    private let audioMixer = AVAudioMixerNode()
    
    /// Underlying AVAudioNode
    var audioNode: AVAudioNode { audioMixer }
    
    init() {}
    
    /// Is this node already connected?
    /// - Parameter node: Node to check
    func hasInput(_ node: JGSAudioNode) -> Bool {
        connections.contains(where: { $0 === node })
    }
    
    /// Add input to the mixer
    /// - Parameter node: Node to add
    func addInput(_ node: JGSAudioNode) {
        assert(!hasInput(node), "Node is already connected to Mixer.")
        inputs.append(node)
        makeConnections()
    }
    
    func silenceOutput() {
        audioMixer.outputVolume = 0
    }
}
