/*
 InteractableControlComponent.swift
 EnvStadium
*/

import RealityKit
import Foundation

enum ControlType {
    case steering
    case power
}

struct InteractableControlComponent: Component {
    var controlType: ControlType
    var currentValue: Float = 0.0
    
    // Used to track which hand is grabbing this control
    var grabbingHandID: UUID? = nil
}
