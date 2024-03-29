//
//  JGSTuner.swift
//  JGSTuner
//
//  Created by 梅继高 on 2023/6/28.
//  Copyright © 2023 MeiJigao. All rights reserved.
//

import AVFoundation
import JGSourceBase

@objcMembers
public final class JGSTuner: NSObject {
    
    private var hasMicrophoneAccess = false
    private var pitchDetector: JGSTunnerDetector?
    public var amplitudeThreshold: Float = 0.025
    public var a4Frequency: Float = JGSTunerStandardA4Frequency
    private lazy var engine = JGSAudioDetector(bufferSize: bufferSize) { [weak self] buffer, time in
        self?.didReceiveAudio = true
        
        DispatchQueue.global().async { [weak self] in
            guard let `self` = self else { return }
            
            if pitchDetector == nil {
                pitchDetector = JGSTunnerDetector(sampleRate: buffer.format.sampleRate, bufferSize: bufferSize)
            }
            
            guard let tunerData = pitchDetector?.analyzePitch(from: buffer, amplitudeThreshold: amplitudeThreshold, a4Frequency: a4Frequency) else { return }
            if let callback = self.frequencyAmplitudeAnalyze {
                callback(tunerData.frequency, tunerData.amplitude, tunerData.names, tunerData.octave, tunerData.distance, tunerData.standardFrequency)
            }
        }
    }
    
    public var bufferSize: UInt32 = 4096
    public var didReceiveAudio = false
    private var showMicrophoneAccessAlert: (() -> Void) = {
        
        let microDesc = Bundle.main.object(forInfoDictionaryKey: "NSMicrophoneUsageDescription") as? String
        let alert = UIAlertController(title: microDesc, message: "请在 设置 -> 隐私与安全 -> 麦克风 设置中允许本应用使用麦克风，以采集音频输入信号。", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "知道了", style: .cancel))
        alert.addAction(UIAlertAction(title: "去设置", style: .default) { _ in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        })
        if #available(iOS 13.0, *) {
            
            for scene in UIApplication.shared.connectedScenes {
                if let winScene = scene as? UIWindowScene, scene.activationState == .foregroundActive {
                    var keyWindow = winScene.windows.first
                    if #available(iOS 15.0, *) {
                        keyWindow = winScene.keyWindow ?? keyWindow
                    }
                    keyWindow?.rootViewController?.present(alert, animated: true)
                    break
                }
            }
        } else {
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true)
        }
    }
    
    private var frequencyAmplitudeAnalyze: ((_ frequency: Float, _ amplitude: Float, _ names: [String], _ octave: Int, _ distance: Float, _ standardFrequency: Float) -> Void)?
    public required init(microphoneAccessAlert: (() -> Void)?) {
        showMicrophoneAccessAlert = microphoneAccessAlert ?? showMicrophoneAccessAlert
    }
    
    private lazy var isStarting = false
    @MainActor
    public func start(analyzeCallback callback: @escaping (_ frequency: Float, _ amplitude: Float, _ names: [String], _ octave: Int, _ distance: Float, _ standardFrequency: Float) -> Void) async -> Bool {
        
        if didReceiveAudio || isStarting {
            return false
        }
        
        isStarting = true
        let startDate = Date()
        var intervalMS: UInt64 = 30
        while !didReceiveAudio {
            
            JGSLog("Waiting \(intervalMS * 2)ms")
            try? await Task.sleep(nanoseconds: intervalMS * NSEC_PER_MSEC)
            hasMicrophoneAccess = await checkMicrophoneAuthorizationStatus()
            try? await Task.sleep(nanoseconds: intervalMS * NSEC_PER_MSEC)
            if hasMicrophoneAccess {
                startEngine()
            } else {
                showMicrophoneAccessAlert()
                isStarting = false
                return false
            }
            intervalMS = min(intervalMS * 2, 180)
            
            let seconds = -startDate.timeIntervalSinceNow
            if seconds > 10 {
                isStarting = false
                JGSLog("Start faild after \(String(format: "%.2fs", seconds))")
                return false
            }
        }
        
        isStarting = false
        frequencyAmplitudeAnalyze = callback
        JGSLog("Took \(String(format: "%.2fs", -startDate.timeIntervalSinceNow)) to start")
        return true
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
            JGSLog("Error")
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
