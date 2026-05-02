//
//  MathUtilities.swift
//  EnvStadium
//
//  Created by Muhammad Tafani Rabbani on 30/04/26.
//

import Foundation
import simd

enum MathUtilities {
    static func lerp(from: Float, to: Float, t: Float) -> Float {
        from + (to - from) * max(0, min(1, t))
    }

    static func clamp<T: Comparable>(_ value: T, min lo: T, max hi: T) -> T {
        min(max(value, lo), hi)
    }

    // remap value from one range to another
    static func map(value: Float, inMin: Float, inMax: Float, outMin: Float, outMax: Float) -> Float {
        outMin + (outMax - outMin) * (value - inMin) / (inMax - inMin)
    }
}
