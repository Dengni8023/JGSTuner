//
//  JGSTunerData.swift
//  JGSTuner
//
//  Created by 梅继高 on 2023/6/25.
//

import Foundation

internal struct JGSTunerData {
    let frequency: JGSTunerFrequency
    let amplitude: Float
    let closestNote: JGSTunerNote.Match
}

extension JGSTunerData {
    
    init(frequency freq: Int = 440, amplitude am: Float) {
        frequency = JGSTunerFrequency(floatLiteral: Double(freq))
        amplitude = am
        closestNote = JGSTunerNote.closestNote(to: frequency)
    }
    
    init(frequency freq: Double = 440.0, amplitude am: Float) {
        frequency = JGSTunerFrequency(floatLiteral: freq)
        amplitude = am
        closestNote = JGSTunerNote.closestNote(to: frequency)
    }
    
    init(frequency freq: Float = 440.0, amplitude am: Float) {
        frequency = JGSTunerFrequency(floatLiteral: Double(freq))
        amplitude = am
        closestNote = JGSTunerNote.closestNote(to: frequency)
    }
}
