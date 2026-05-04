import Foundation

struct SimulationConfig {
    // Interaction
    var interactionRange: Float = 0.25
    var relativeGrabSensitivity: Float = 4.0
    var tankDriveSteeringDeadzone: Float = 0.15
    
    // Cockpit
    var cockpitScale: Float = 0.75
    var throttleVisualTilt: Float = 0.6
    
    // Physics
    var maxSpeed: Float = 20.0
    var steeringSensitivity: Float = 0.8
    var bankSensitivity: Float = 0.25
    var lerpSpeed: Float = 3.0
    
    static let shared = SimulationConfig()
}
