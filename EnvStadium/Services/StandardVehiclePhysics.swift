import RealityKit
import simd

struct StandardVehiclePhysics: VehiclePhysicsEngine {
    func update(entity: Entity, component: inout VehicleComponent, throttle: Float, steer: Float, config: SimulationConfig, dt: Float) {
        
        // Update orientation based on steering
        component.headingAngle += -steer * config.steeringSensitivity * dt
        component.bankAngle     = MathUtilities.lerp(from: component.bankAngle, to: -steer * config.bankSensitivity, t: dt * config.lerpSpeed)

        entity.orientation = simd_quatf(angle: Float(component.headingAngle), axis: [0, 1, 0])
                           * simd_quatf(angle: Float(component.bankAngle),    axis: [0, 0, 1])

        // Update speed and position
        let targetSpeed = config.maxSpeed * throttle
        component.speed = MathUtilities.lerp(from: component.speed, to: targetSpeed, t: dt * config.lerpSpeed)
        
        let forward = entity.transform.matrix.columns.2.xyz
        entity.position += forward * component.speed * dt
    }
}
