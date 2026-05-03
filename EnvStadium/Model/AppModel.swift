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

    enum ImmersiveSpaceState {
        case closed, inTransition, open
    }

    var immersiveSpaceState: ImmersiveSpaceState = .closed

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
