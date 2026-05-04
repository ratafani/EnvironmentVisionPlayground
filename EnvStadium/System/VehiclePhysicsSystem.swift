import RealityKit
import Foundation

struct VehiclePhysicsSystem: System {
    static let vehicleQuery = EntityQuery(where: .has(VehicleComponent.self))
    static let serviceQuery = EntityQuery(where: .has(AppModelServiceComponent.self))
    
    private let engine: VehiclePhysicsEngine = StandardVehiclePhysics()
    
    init(scene: RealityKit.Scene) {}
    
    func update(context: SceneUpdateContext) {
        guard let serviceEntity = context.entities(matching: Self.serviceQuery, updatingSystemWhen: .rendering).first(where: { _ in true }),
              let appModel = serviceEntity.components[AppModelServiceComponent.self]?.appModel else {
            return
        }
        
        let vehicles = context.entities(matching: Self.vehicleQuery, updatingSystemWhen: .rendering)
        let dt = Float(context.deltaTime)
        
        // Calculate throttle: If both are used, average them. If only one is used, use that one.
        let left = appModel.leftThrottleInput
        let right = appModel.rightThrottleInput
        let avgThrottle: Float
        if left != 0 && right != 0 {
            avgThrottle = (left + right) / 2.0
        } else {
            avgThrottle = left != 0 ? left : right
        }
        
        for vehicle in vehicles {
            guard var vc = vehicle.components[VehicleComponent.self] else { continue }
            
            engine.update(entity: vehicle, 
                          component: &vc, 
                          throttle: avgThrottle, 
                          steer: appModel.steeringInput, 
                          config: .shared, 
                          dt: dt)
            
            vehicle.components.set(vc)
            
            // Sync with AppModel for UI
            Task { @MainActor in
                appModel.vehicleSpeed = vc.speed
                appModel.steeringAngle = appModel.steeringInput
            }
        }
    }
}
