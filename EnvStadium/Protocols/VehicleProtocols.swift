import RealityKit
import Foundation

/// Protocol for objects that can control a vehicle's state
protocol VehicleController {
    var throttleInput: Float { get set }
    var steeringInput: Float { get set }
    var vehicleSpeed: Float { get set }
}

/// Protocol for interpreting hand tracking data into control inputs
protocol InteractionInterpreter {
    func interpret(hands: [Entity], controls: [Entity], cockpit: Entity?, config: SimulationConfig) -> (leftThrottle: Float, rightThrottle: Float, steering: Float)
}

/// Protocol for the physics engine that moves the vehicle
protocol VehiclePhysicsEngine {
    func update(entity: Entity, component: inout VehicleComponent, throttle: Float, steer: Float, config: SimulationConfig, dt: Float)
}
