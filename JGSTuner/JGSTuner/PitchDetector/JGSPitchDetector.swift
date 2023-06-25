//
//  JGSPitchDetector.swift
//  JGSTuner
//
//  Created by 梅继高 on 2023/6/25.
//

import AVFoundation

internal final class JGSPitchDetector {
    
    private var data: UnsafeMutablePointer<zt_data>?
    private var ptrack: UnsafeMutablePointer<zt_ptrack>?
    
    public init(sampleRate: Double, bufferSize: UInt32, peakCount: UInt32 = 20) {
        withUnsafeMutablePointer(to: &data, zt_create)
        data!.pointee.sr = Int32(sampleRate)
        withUnsafeMutablePointer(to: &ptrack, zt_ptrack_create)
        zt_ptrack_init(data, ptrack, Int32(bufferSize), Int32(peakCount))
    }
    
    deinit {
        withUnsafeMutablePointer(to: &ptrack, zt_ptrack_destroy)
        withUnsafeMutablePointer(to: &data, zt_destroy)
    }
    
    public func analyzePitch(from buffer: AVAudioPCMBuffer, amplitudeThreshold amThreshold: Float = 0.025) -> JGSTunerData? {
        
        guard let floatData = buffer.floatChannelData else { return nil }

        var frequency: Float = 0
        var amplitude: Float = 0
        
        let frames = (0..<Int(buffer.frameLength)).map { floatData[0].advanced(by: $0) }
        for frame in frames {
            zt_ptrack_compute(data, ptrack, frame, &frequency, &amplitude)
        }
        
        if amplitude > amThreshold, frequency >= 70 {
            return JGSTunerData(frequency: frequency, amplitude: amplitude)
        } else {
            return nil
        }
    }
}
