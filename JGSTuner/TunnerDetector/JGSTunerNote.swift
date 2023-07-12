//
//  JGSTunerNote.swift
//  JGSTuner
//
//  Created by 梅继高 on 2023/6/28.
//  Copyright © 2023 MeiJigao. All rights reserved.
//

import Foundation

private let JGSTunerStandardA4Frequency: Double = 440.0
private let JGSTunerStandardA0Frequency: Double = JGSTunerStandardA4Frequency / pow(2.0, 4 - 0)
private let JGSTunerFrequencyDelta = pow(2.0, 1.0 / 12.0)
internal enum JGSTunerNote: Int, CaseIterable, Identifiable {
    case C, CSharp_DFlat, D, DSharp_EFlat, E, F, FSharp_GFlat, G, GSharp_AFlat, A, ASharp_BFlat, B
    var id: Int { rawValue }

    /// The names for this note.
    var names: [String] {
        switch self {
        case .C:
            return ["C"]
        case .CSharp_DFlat:
            return ["C♯", "D♭"]
        case .D:
            return ["D"]
        case .DSharp_EFlat:
            return ["D♯", "E♭"]
        case .E:
            return ["E"]
        case .F:
            return ["F"]
        case .FSharp_GFlat:
            return ["F♯", "G♭"]
        case .G:
            return ["G"]
        case .GSharp_AFlat:
            return ["G♯", "A♭"]
        case .A:
            return ["A"]
        case .ASharp_BFlat:
            return ["A♯", "B♭"]
        case .B:
            return ["B"]
        }
    }

    /// The frequency for this note at the 0th octave in standard pitch: https://en.wikipedia.org/wiki/Standard_pitch
    /// center 4 group
    var frequency: Double {
        switch self {
        case .C:
            return JGSTunerStandardA0Frequency / pow(JGSTunerFrequencyDelta, 9)
        case .CSharp_DFlat:
            return JGSTunerStandardA0Frequency / pow(JGSTunerFrequencyDelta, 8)
        case .D:
            return JGSTunerStandardA0Frequency / pow(JGSTunerFrequencyDelta, 7)
        case .DSharp_EFlat:
            return JGSTunerStandardA0Frequency / pow(JGSTunerFrequencyDelta, 6)
        case .E:
            return JGSTunerStandardA0Frequency / pow(JGSTunerFrequencyDelta, 5)
        case .F:
            return JGSTunerStandardA0Frequency / pow(JGSTunerFrequencyDelta, 4)
        case .FSharp_GFlat:
            return JGSTunerStandardA0Frequency / pow(JGSTunerFrequencyDelta, 3)
        case .G:
            return JGSTunerStandardA0Frequency / pow(JGSTunerFrequencyDelta, 2)
        case .GSharp_AFlat:
            return JGSTunerStandardA0Frequency / pow(JGSTunerFrequencyDelta, 1)
        case .A:
            return JGSTunerStandardA0Frequency / pow(JGSTunerFrequencyDelta, 0)
        case .ASharp_BFlat:
            return JGSTunerStandardA0Frequency / pow(JGSTunerFrequencyDelta, -1)
        case .B:
            return JGSTunerStandardA0Frequency / pow(JGSTunerFrequencyDelta, -2)
        }
    }
    
    /// Find the closest note to the specified frequency.
    /// - Parameters:
    ///   - inFreq: The frequency to match against.
    ///   - a4Freq: The standard A4 frequency
    /// - Returns: The closest note match.
    static func closestNote(to inFreq: Double, standardA4Frequency a4Freq: Double = JGSTunerStandardA4Frequency) -> JGSTunerNoteMatch {
        
        //
        let frequency = inFreq * JGSTunerStandardA4Frequency / a4Freq
        
        // Shift frequency octave to be within range of scale note frequencies.
        var octaveShiftedFrequency = frequency
        while octaveShiftedFrequency > allCases.last!.frequency {
            octaveShiftedFrequency.jg_shift(byOctaves: -1)
        }
        
        while octaveShiftedFrequency < allCases.first!.frequency {
            octaveShiftedFrequency.jg_shift(byOctaves: 1)
        }
        
        // Find closest note
        let closestNote = allCases.min(by: { note1, note2 in
            fabs(note1.frequency.jg_distance(to: octaveShiftedFrequency).cents) < fabs(note2.frequency.jg_distance(to: octaveShiftedFrequency).cents)
        })!

        let fastOctave = max(octaveShiftedFrequency.jg_distanceInOctaves(to: frequency), 0)
        let fastResult = JGSTunerNoteMatch(
            note: closestNote,
            octave: fastOctave,
            distance: closestNote.frequency.jg_distance(to: octaveShiftedFrequency)
        )
        
        // Fast result can be incorrect at the scale boundary
        guard (fastResult.note == .C && fastResult.distance.cents < 0) ||
            (fastResult.note == .B && fastResult.distance.cents > 0) else {
            return fastResult
        }
        
        var match: JGSTunerNoteMatch?
        for octave in [fastOctave, fastOctave + 1] {
            for note in [JGSTunerNote.C, .B] {
                let distance = note.frequency.jg_shifted(byOctaves: octave).jg_distance(to: frequency)
                if let match = match, abs(distance.cents) > abs(match.distance.cents) {
                    return match
                } else {
                    match = JGSTunerNoteMatch(
                        note: note,
                        octave: octave,
                        distance: distance
                    )
                }
            }
        }

        print("Closest note could not be found")
        return fastResult
    }

}

/// A note match given an input frequency.
internal struct JGSTunerNoteMatch {
    /// The matched note.
    let note: JGSTunerNote
    /// The octave of the matched note.
    let octave: Int
    /// The distance between the input frequency and the matched note's defined frequency.
    let distance: JGSTunerNoteDistance

    /// The frequency of the matched note, adjusted by octave.
    var frequency: Double { note.frequency.jg_shifted(byOctaves: octave) }
}

internal struct JGSTunerNoteDistance {
    
    /// Humans can distinguish a difference in pitch of about 5–6 cents:
    /// https://en.wikipedia.org/wiki/Cent_%28music%29#Human_perception
    var isPerceptible: Bool { abs(cents) > 6 }

    /// The distance in a full octave.
    static var octave = JGSTunerNoteDistance(cents: 1200) //  1200√2 或 pow(2, 1.0 / 1200.0)
    
    /// Underlying float value. Between -50 and +50.
    let cents: Double
    
    init(cents: Double) {
        self.cents = cents
    }
}

internal extension Double {
    
    /// Calculate distance to given frequency in musical cents.
    /// - parameter frequency: Frequency to compare against.
    /// - returns: The distance in cents.
    func jg_distance(to frequency: Double) -> JGSTunerNoteDistance {
        return JGSTunerNoteDistance(cents:
            JGSTunerNoteDistance.octave.cents * log2(frequency / self)
        )
    }
    
    /// Computes the distance in octaves between the current frequency and the specified frequency. Truncates if distance is not exact octaves.
    /// - parameter frequency: Frequency to compare.
    /// - returns: Distance in octaves to specified frequency.
    func jg_distanceInOctaves(to frequency: Double) -> Int {
        return Int(jg_distance(to: frequency).cents / JGSTunerNoteDistance.octave.cents)
    }
    
    /// Returns the current frequency shifted by increasing or decreasing in discrete octave increments.
    /// - parameter octaves: The number of octaves to transpose this frequency. Can be positive or negative.
    /// - returns: Octave shifted frequency.
    func jg_shifted(byOctaves octaves: Int) -> Double {
        var copy = self
        copy.jg_shift(byOctaves: octaves)
        return copy
    }

    /// Shifts the frequency by increasing or decreasing in discrete octave increments.
    /// - parameter octaves: The number of octaves to transpose this frequency. Can be positive or negative.
    mutating func jg_shift(byOctaves octaves: Int) {
        if octaves == 0 {
            return
        } else {
            self *= pow(2.0, Double(octaves))
        }
    }
}
