import RealityKit
import Foundation

struct CockpitVisualSystem: System {
    static let cockpitQuery = EntityQuery(where: .has(CockpitComponent.self))
    static let serviceQuery = EntityQuery(where: .has(AppModelServiceComponent.self))
    
    init(scene: RealityKit.Scene) {}
    
    func update(context: SceneUpdateContext) {
        guard let serviceEntity = context.entities(matching: Self.serviceQuery, updatingSystemWhen: .rendering).first(where: { _ in true }),
              let appModel = serviceEntity.components[AppModelServiceComponent.self]?.appModel else {
            return
        }
        
        let cockpits = context.entities(matching: Self.cockpitQuery, updatingSystemWhen: .rendering)
        let config = SimulationConfig.shared
        
        for cockpit in cockpits {
            guard var comp = cockpit.components[CockpitComponent.self] else { continue }
            
            // 1. Update Steering Wheel
            if let wheel = comp.steeringWheel {
                wheel.orientation = simd_quatf(angle: appModel.steeringInput / 1.5, axis: [0, 0, 1])
            }
            
            // 2. Update Throttles
            comp.leftThrottle?.orientation = simd_quatf(angle: -appModel.leftThrottleInput * config.throttleVisualTilt, axis: [1, 0, 0])
            comp.rightThrottle?.orientation = simd_quatf(angle: -appModel.rightThrottleInput * config.throttleVisualTilt, axis: [1, 0, 0])
            
            cockpit.components.set(comp)
        }
    }
}
