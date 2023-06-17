//
//  JGSMicrophoneDetector.swift
//  JGSTuner
//
//  Created by 梅继高 on 2023/6/7.
//

import AVFoundation

@objcMembers
open class JGSMicrophoneDetector {
    
    private var hasMicrophoneAccess = false
    private var audioNodeTapBlock: AVAudioNodeTapBlock = { (buffer, time) in }
    private lazy var engine = JGSAudioEngine { [weak self] (buffer, time) in
        self?.didReceiveAudio = true
        self?.audioNodeTapBlock(buffer, time)
    }
    
    public var pitch: Double = 440
    public var didReceiveAudio = false
    public var showMicrophoneAccessAlert: (() -> Void) = {}
    
    public required init(_ tapBlock: @escaping AVAudioNodeTapBlock, microphoneAccessAlert: @escaping () -> Void) {
        audioNodeTapBlock = tapBlock
        showMicrophoneAccessAlert = microphoneAccessAlert
    }
    
    @MainActor
    public func start(debug: Bool = false) async {
        
        if didReceiveAudio {
            return
        }
        
        let startDate = Date()
        var intervalMS: UInt64 = 30
        while !didReceiveAudio {
            if debug {
                print("Waiting \(intervalMS * 2)ms")
            }
            try? await Task.sleep(nanoseconds: intervalMS * NSEC_PER_MSEC)
            hasMicrophoneAccess = await checkMicrophoneAuthorizationStatus()
            try? await Task.sleep(nanoseconds: intervalMS * NSEC_PER_MSEC)
            if hasMicrophoneAccess {
                startEngine()
            } else {
                break
            }
            intervalMS = min(intervalMS * 2, 180)
        }

        if debug {
            let duration = String(format: "%.2fs", -startDate.timeIntervalSinceNow)
            print("Took \(duration) to start")
        }
        
//        checkMicrophoneAuthorizationStatus { [weak self] granted in
//
//            self?.hasMicrophoneAccess = granted
//            guard granted else {
//                self?.showMicrophoneAccessAlert()
//                return
//            }
//
//            self?.startEngine()
//        }
    }
    
    @MainActor
    public func stop() {
        guard hasMicrophoneAccess && didReceiveAudio else { return }
        engine.stop()
        didReceiveAudio = false
    }
    
    // MARK: - Private
    
    @MainActor
    private func startEngine() {
        guard hasMicrophoneAccess && !didReceiveAudio else { return }
        
        do {
            try engine.start()
        } catch {
            // TODO: Handle error
            print("Error")
        }
    }
    
    @MainActor
    private func checkMicrophoneAuthorizationStatus() async -> Bool {
        guard !hasMicrophoneAccess else { return true }
        
        return await withUnsafeContinuation { continuation in
            
            switch AVCaptureDevice.authorizationStatus(for: .audio) {
            case .authorized: // The user has previously granted access to the microphone.
                continuation.resume(returning: true)
            case .notDetermined: // The user has not yet been asked for microphone access.
                AVCaptureDevice.requestAccess(for: .audio) { granted in
                    continuation.resume(returning: granted)
                }
            case .denied: // The user has previously denied access.
                continuation.resume(returning: false)
            case .restricted: // The user can't grant access due to restrictions.
                continuation.resume(returning: false)
            @unknown default:
                continuation.resume(returning: false)
            }
        }
    }
}
