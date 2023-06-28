//
//  JGSTunnerDetector.swift
//  JGSTuner
//
//  Created by 梅继高 on 2023/6/28.
//  Copyright © 2023 MeiJigao. All rights reserved.
//

import Foundation

internal final class JGSTunnerDetector {
    
    private var data: UnsafeMutablePointer<zt_data>?
    private var ptrack: UnsafeMutablePointer<zt_ptrack>?
    private var ignoreCnt: Int = 0
    
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
    
    /// 频率分析
    /// - Parameters:
    ///   - buffer: 采样数据
    ///   - amThreshold: 振幅阈值
    ///   - ignore: 满足振幅阈值后，忽略几个点
    /// - Returns: JGSTunerData?
    public func analyzePitch(from buffer: AVAudioPCMBuffer, amplitudeThreshold amThreshold: Float = 0.025, ignore: Int = 3) -> JGSTunerData? {

        // 数据异常
        guard let floatData = buffer.floatChannelData else { return nil }

        var frequency: Float = 0
        var amplitude: Float = 0
        
        let frames = (0..<Int(buffer.frameLength)).map { floatData[0].advanced(by: $0) }
        for frame in frames {
            zt_ptrack_compute(data, ptrack, frame, &frequency, &amplitude)
        }
        
        // 振幅不满足
        guard amplitude > amThreshold else {
            ignoreCnt = 0
            return nil
        }
        
        // 忽略点
        ignoreCnt += 1
        guard ignoreCnt > ignore else {
            return nil
        }
        
        // 频率不满足
        guard frequency >= 70 else {
            return nil
        }
        
        return  JGSTunerData(frequency: frequency, amplitude: amplitude)
    }
}
