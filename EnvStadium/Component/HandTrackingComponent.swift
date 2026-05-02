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
}
