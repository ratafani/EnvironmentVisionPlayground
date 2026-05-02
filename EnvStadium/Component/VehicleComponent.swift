/*
 VehicleComponent.swift
 EnvStadium
*/

import RealityKit

struct VehicleComponent: Component {
    var speed: Float = 0.0
    var maxSpeed: Float = 5.0
    var turnRate: Float = 0.5
    var bankAngle: Float = 0.0      // Z-axis roll, smoothly interpolated
    var headingAngle: Float = 0.0   // Y-axis yaw, accumulated over time
    
    var targetSpeed: Float = 0.0
    var targetTurnRate: Float = 0.0
}
