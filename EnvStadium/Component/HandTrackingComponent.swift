/*
 HandTrackingComponent.swift
 EnvStadium
*/

import RealityKit
import ARKit

struct HandTrackingComponent: Component {
    var chirality: HandAnchor.Chirality
    var isGrabbing: Bool = false
    
    // Store relevant joint positions for control interaction
    var wristPosition: SIMD3<Float> = .zero
    var palmPosition: SIMD3<Float> = .zero
    
    // For relative movement (e.g. throttle)
    var initialGrabPosition: SIMD3<Float>? = nil
    
    // Finger states for debugging
    var thumbCurled: Bool = false
    var indexCurled: Bool = false
    var middleCurled: Bool = false
    var ringCurled: Bool = false
    var pinkyCurled: Bool = false
    
    // Anti-jitter
    var grabFrameCount: Int = 0
    var isGrabbingFiltered: Bool = false
}
