import RealityKit
import RealityKitContent
import SwiftUI

struct CockpitFactory {
    
    @MainActor
    static func create(useSteeringWheel: Bool) async -> Entity {
        let root = Entity()
        root.name = "Cockpit"
        root.scale = SIMD3<Float>(repeating: SimulationConfig.shared.cockpitScale)
        
        // 1. Load Assets via Service
        var cockpitComp = CockpitComponent(useSteeringWheel: useSteeringWheel)
        
        if let asset = try? await ResourceService.shared.loadEntity(named: "cockpit") {
            asset.scale = [0.6,0.6,0.6]
            root.addChild(asset)
            cockpitComp.leftThrottle = asset.findEntity(named: "ThrottleController_001") ?? asset.findEntity(named: "ThrottleController.001")
            cockpitComp.rightThrottle = asset.findEntity(named: "ThrottleController_002") ?? asset.findEntity(named: "ThrottleController.002")
        }
        
        // 2. Setup Lighting
        let lamp = Entity()
        lamp.components.set(PointLightComponent(color: .white, attenuationRadius: 100))
        lamp.position = [0, 1.5, -0.45]
        root.addChild(lamp)
        
        // 3. Setup Interaction Components
        setupInteractions(for: [cockpitComp.leftThrottle, cockpitComp.rightThrottle].compactMap { $0 })
        
        // 4. Create Steering Wheel (initially based on setting)
        cockpitComp.steeringWheel = createSteeringWheel()
        root.addChild(cockpitComp.steeringWheel!)
        cockpitComp.steeringWheel?.isEnabled = useSteeringWheel
        
        root.components.set(cockpitComp)
        return root
    }
    
    private static func setupInteractions(for entities: [Entity]) {
        for entity in entities {
            entity.components.set(InputTargetComponent())
            let shape = ShapeResource.generateSphere(radius: 0.15)
            var collision = CollisionComponent(shapes: [shape], isStatic: true)
            collision.filter = CollisionFilter(group: .all, mask: .all)
            entity.components.set(collision)
            entity.components.set(InteractableControlComponent(controlType: .power))
        }
    }
    
    private static func createSteeringWheel() -> Entity {
        let wheel = ModelEntity(mesh: .generateCylinder(height: 0.02, radius: 0.12), 
                                materials: [SimpleMaterial(color: .black, isMetallic: true)])
        wheel.name = "SteeringWheel"
        wheel.position = [0, 0.7, -0.45]
        wheel.orientation = simd_quatf(angle: .pi/2.5, axis: [1, 0, 0])
        
        wheel.components.set(InputTargetComponent())
        wheel.components.set(CollisionComponent(shapes: [.generateSphere(radius: 0.15)]))
        wheel.components.set(InteractableControlComponent(controlType: .steering))
        return wheel
    }
}
