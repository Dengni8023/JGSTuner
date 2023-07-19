//
//  JGSTunerNote.swift
//  JGSTuner
//
//  Created by 梅继高 on 2023/6/28.
//  Copyright © 2023 MeiJigao. All rights reserved.
//

import Foundation
import JGSourceBase

public let JGSTunerStandardA4Frequency: Float = 440.0
private let JGSTunerStandardA0Frequency: Float = JGSTunerStandardA4Frequency / powf(2.0, 4 - 0)
private let JGSTunerFrequencyDelta: Float = powf(2.0, 1.0 / 12.0)

// C0: 16.35159783128741
public func JGSTunerMinFrequency(_ a4Frequency: Float = JGSTunerStandardA4Frequency) -> Float {
    return JGSTunerNoteMatch(note: .C, octave: 0, distance: 0).frequency * JGSTunerStandardA4Frequency / a4Frequency
}

// B8: 7902.132820097986
public func JGSTunerMaxFrequency(_ a4Frequency: Float = JGSTunerStandardA4Frequency) -> Float {
    return JGSTunerNoteMatch(note: .B, octave: 8, distance: 0).frequency * JGSTunerStandardA4Frequency / a4Frequency
}

public enum JGSTunerNote: Int, CaseIterable, Identifiable {
    case C, CSharp_DFlat, D, DSharp_EFlat, E, F, FSharp_GFlat, G, GSharp_AFlat, A, ASharp_BFlat, B
    public var id: Int { rawValue }
    
    /// The names for this note.
    public var names: [String] {
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
    public var frequency: Float {
        switch self {
        case .C:
            return JGSTunerStandardA0Frequency / powf(JGSTunerFrequencyDelta, 9)
        case .CSharp_DFlat:
            return JGSTunerStandardA0Frequency / powf(JGSTunerFrequencyDelta, 8)
        case .D:
            return JGSTunerStandardA0Frequency / powf(JGSTunerFrequencyDelta, 7)
        case .DSharp_EFlat:
            return JGSTunerStandardA0Frequency / powf(JGSTunerFrequencyDelta, 6)
        case .E:
            return JGSTunerStandardA0Frequency / powf(JGSTunerFrequencyDelta, 5)
        case .F:
            return JGSTunerStandardA0Frequency / powf(JGSTunerFrequencyDelta, 4)
        case .FSharp_GFlat:
            return JGSTunerStandardA0Frequency / powf(JGSTunerFrequencyDelta, 3)
        case .G:
            return JGSTunerStandardA0Frequency / powf(JGSTunerFrequencyDelta, 2)
        case .GSharp_AFlat:
            return JGSTunerStandardA0Frequency / powf(JGSTunerFrequencyDelta, 1)
        case .A:
            return JGSTunerStandardA0Frequency / powf(JGSTunerFrequencyDelta, 0)
        case .ASharp_BFlat:
            return JGSTunerStandardA0Frequency / powf(JGSTunerFrequencyDelta, -1)
        case .B:
            return JGSTunerStandardA0Frequency / powf(JGSTunerFrequencyDelta, -2)
        }
    }
    
    /// Find the closest note to the specified frequency.
    /// - Parameters:
    ///   - inFreq: The frequency to match against.
    ///   - a4Frequency: The standard A4 frequency
    /// - Returns: The closest note match.
    public static func closestNote(to inFreq: Float, a4Frequency: Float = JGSTunerStandardA4Frequency) -> JGSTunerNoteMatch {
        
        // translate frequency to A4=440
        let frequency = inFreq * JGSTunerStandardA4Frequency / a4Frequency
        
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
            fabsf(note1.frequency.jg_distance(to: octaveShiftedFrequency)) < fabsf(note2.frequency.jg_distance(to: octaveShiftedFrequency))
        })!
        
        let fastOctave = max(octaveShiftedFrequency.jg_distanceInOctaves(to: frequency), 0)
        let fastResult = JGSTunerNoteMatch(
            note: closestNote,
            octave: fastOctave,
            distance: closestNote.frequency.jg_distance(to: octaveShiftedFrequency)
        )
        
        // Fast result can be incorrect at the scale boundary
        guard (fastResult.note == .C && fastResult.distance < 0) ||
            (fastResult.note == .B && fastResult.distance > 0) else {
            return fastResult
        }
        
        var match: JGSTunerNoteMatch?
        for octave in [fastOctave, fastOctave + 1] {
            for note in [JGSTunerNote.C, .B] {
                let distance = note.frequency.jg_shifted(byOctaves: octave).jg_distance(to: frequency)
                if let match = match, abs(distance) > abs(match.distance) {
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
    
    /// Find the note to the specified toneName.
    /// - Parameter toneName: toneName eg. F♯2 /  E♭3
    /// - Returns: The note match.
    public static func note(with toneNames: [String]) -> [JGSTunerNoteMatch?]? {
        
        var matches: [JGSTunerNoteMatch?] = []
        toneNames.forEach { toneName in
            matches.append(note(with: toneName))
        }
        return matches
    }
    
    /// Find the note to the specified toneName.
    /// - Parameter toneName: toneName eg. F♯2 /  E♭3
    /// - Returns: The note match.
    public static func note(with toneName: String) -> JGSTunerNoteMatch? {
        
        guard let octaveReg = try? NSRegularExpression(pattern: "[0-9]", options: [.caseInsensitive]) else { return nil }
        let noteName = octaveReg.stringByReplacingMatches(in: toneName, range: NSRange(location: 0, length: toneName.count), withTemplate: "")
        
        guard let noteReg = try? NSRegularExpression(pattern: "[A-Z♯♭]", options: [.caseInsensitive]) else { return nil }
        let octave = Int.jg_transform(from: noteReg.stringByReplacingMatches(in: toneName, range: NSRange(location: 0, length: toneName.count), withTemplate: "")) ?? 0
        
        return note(with: noteName, octave: octave)
    }
    
    /// Find the note to the specified toneName.
    /// - Parameters:
    ///   - note: noteName eg. F♯ /  E♭
    ///   - octave: octave eg. 2
    /// - Returns: The note match.
    private static func note(with note: String, octave: Int) -> JGSTunerNoteMatch? {
        for caseNote in allCases {
            if caseNote.names.contains(note) {
                return JGSTunerNoteMatch(
                    note: caseNote,
                    octave: octave,
                    distance: 0
                )
            }
        }
        return nil
    }
}

/// A note match given an input frequency.
public struct JGSTunerNoteMatch {
    /// The matched note.
    public var note: JGSTunerNote
    /// The octave of the matched note.
    public var octave: Int
    /// The distance between the input frequency and the matched note's defined frequency.
    /// Underlying float value. Between -50 and +50.
    public var distance: Float

    /// The frequency of the matched note, adjusted by octave.
    public var frequency: Float { note.frequency.jg_shifted(byOctaves: octave) }
    
    /// Humans can distinguish a difference in pitch of about 5–6 cents:
    /// https://en.wikipedia.org/wiki/Cent_%28music%29#Human_perception
    public var isPerceptible: Bool { abs(distance) > 6 }
    
    /// The distance in a full octave.
    fileprivate static var octaveCents: Float = 1200 //  1200√2 或 pow(2, 1.0 / 1200.0)
}

internal extension Float {
    
    /// Calculate distance to given frequency in musical cents.
    /// - parameter frequency: Frequency to compare against.
    /// - returns: The distance in cents.
    func jg_distance(to frequency: Float) -> Float {
        return JGSTunerNoteMatch.octaveCents * log2f(frequency / self)
    }
    
    /// Computes the distance in octaves between the current frequency and the specified frequency. Truncates if distance is not exact octaves.
    /// - parameter frequency: Frequency to compare.
    /// - returns: Distance in octaves to specified frequency.
    func jg_distanceInOctaves(to frequency: Float) -> Int {
        return Int(jg_distance(to: frequency) / JGSTunerNoteMatch.octaveCents)
    }
    
    /// Returns the current frequency shifted by increasing or decreasing in discrete octave increments.
    /// - parameter octaves: The number of octaves to transpose this frequency. Can be positive or negative.
    /// - returns: Octave shifted frequency.
    func jg_shifted(byOctaves octaves: Int) -> Float {
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
            self *= powf(2.0, Float(octaves))
        }
    }
}

public extension JGSTuner {
    
    /// Find the note to the specified toneName.
    /// - Parameter toneName: toneName eg. F♯2 /  E♭3
    /// - Returns: The note match.
    static func notes(with toneNames: [String]) -> [[String: Any]]? {
        
        var matches: [[String: Any]] = []
        toneNames.forEach { toneName in
            if let match = JGSTunerNote.note(with: toneName) {
                matches.append([
                    "note": match.note.names,
                    "octave": match.octave,
                    "distance": match.distance,
                    "frequency": match.frequency,
                ])
            } else {
                matches.append([:])
            }
        }
        return matches
    }
    
    /// Find the note to the specified toneName.
    /// - Parameter toneName: toneName eg. F♯2 /  E♭3
    /// - Returns: The note match.
    static func note(with toneName: String) -> [String: Any]? {

        if let match = JGSTunerNote.note(with: toneName) {
            return [
                "note": match.note.names,
                "octave": match.octave,
                "distance": match.distance,
                "frequency": match.frequency,
            ]
        }
        return [:]
    }
}
