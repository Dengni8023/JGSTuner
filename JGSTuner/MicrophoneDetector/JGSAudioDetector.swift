//
//  JGSAudioDetector.swift
//  JGSTuner
//
//  Created by 梅继高 on 2023/6/28.
//  Copyright © 2023 MeiJigao. All rights reserved.
//

import AVFoundation

/// AudioKit's wrapper for AVAudioEngine
internal final class JGSAudioDetector {
    
    /// Internal AVAudioEngine
    private lazy var audioEngine = AVAudioEngine()
    private lazy var session = AVAudioSession.sharedInstance()
    
    /// Main mixer at the end of the signal chain
    private var mainMixerNode: JGSNodeMixer?
    
    /// Input for microphone is created when this is accessed
    lazy var inputNode: JGSNodeMixer = {
        let _input = JGSNodeMixer()
        audioEngine.attach(_input.audioNode)
        audioEngine.connect(audioEngine.inputNode, to: _input.audioNode, format: nil)
        
        // create the on demand mixer if needed
        createEngineMixer()
        mainMixerNode?.addInput(_input)
        
        return _input
    }()

    /// Empty initializer
    required init(bufferSize size: UInt32, _ tapBlock: @escaping AVAudioNodeTapBlock) {
        bufferSize = size
        audioNodeTapBlock = tapBlock
    }
    
    private var bufferSize: UInt32 = 4096
    private var audioNodeTapBlock: AVAudioNodeTapBlock = { (buffer, time) in }
    
    /// Start the engine
    func start() throws {
        
        try session.setCategory(.playAndRecord, options: [.defaultToSpeaker, .mixWithOthers])
        try session.setActive(true)
        
        inputNode.audioNode.removeTap(onBus: 0)
        inputNode.audioNode.installTap(onBus: 0, bufferSize: bufferSize, format: nil) { [weak self] (buffer, time) in
            if let tapBlock = self?.audioNodeTapBlock {
                tapBlock(buffer, time)
            } else {
                //print("\(#function), Line: \(#line) buffer: \(buffer.frameLength), \(buffer.frameCapacity), time: \(time)")
            }
        }
        
        audioEngine.prepare()
        try audioEngine.start()
    }
    
    /// Stopping the engine releases the resources allocated by prepare.
    func stop() {
        inputNode.audioNode.removeTap(onBus: 0)
        audioEngine.stop()
    }
    
    // MARK: - Private
    
    // simulate the AVAudioEngine.mainMixerNode, but create it ourselves to ensure the
    // correct sample rate is used from .stereo
    private func createEngineMixer() {
        guard mainMixerNode == nil else { return }

        let mixer = JGSNodeMixer()
        audioEngine.attach(mixer.audioNode)
        audioEngine.connect(mixer.audioNode, to: audioEngine.outputNode, format: .JGSTunerStereo)
        mainMixerNode = mixer
        mixer.silenceOutput()
    }
}
