//
//  AppModel.swift
//  EnvStadium
//
//  Created by Muhammad Tafani Rabbani on 30/04/26.
//

import SwiftUI

@MainActor
@Observable
class AppModel {
    let immersiveSpaceID = "ImmersiveSpace"
    let debugWindowID = "DebugWindow"

    struct HandDebugInfo {
        var isTracked: Bool = false
        var isGrabbing: Bool = false
        var indexCurled: Bool = false
        var middleCurled: Bool = false
        var ringCurled: Bool = false
        var pinkyCurled: Bool = false
        var thumbCurled: Bool = false
        var nearestControlName: String? = nil
        var nearestControlDistance: Float? = nil
        var localPosition: SIMD3<Float>? = nil
    }

    var leftHandDebug = HandDebugInfo()
    var rightHandDebug = HandDebugInfo()

    enum ImmersiveSpaceState {
        case closed, inTransition, open
    }

    var immersiveSpaceState: ImmersiveSpaceState = .closed
    
    // Level selection
    var selectedLevel: LevelConfig = StadiumLevel()

    // car state
    var vehicleSpeed: Float = 0.0
    var steeringAngle: Float = 0.0
    var steeringInput: Float = 0.0  // -1 left, +1 right
    
    // Individual throttle inputs for Tank Drive logic
    var leftThrottleInput: Float = 0.0
    var rightThrottleInput: Float = 0.0

    // settings
    var useSteeringWheel: Bool = false
    var steeringSensitivity: Float = 1.0
    var throttleSensitivity: Float = 1.0

    // error — mainly for simulator where hand tracking won't work
    var errorMessage: String?
    var showErrorAlert: Bool = false
}
