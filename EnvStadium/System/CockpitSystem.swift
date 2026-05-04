import RealityKit

struct CockpitSystem: System {
    static let query = EntityQuery(where: .has(CockpitComponent.self))
    
    init(scene: RealityKit.Scene) {}
    
    func update(context: SceneUpdateContext) {
        let entities = context.entities(matching: Self.query, updatingSystemWhen: .rendering)
        
        for entity in entities {
            guard var cockpit = entity.components[CockpitComponent.self] else { continue }
            
            // 1. Handle Animation In (First frame only)
            if !cockpit.isInitialized {
                animateIn(entity)
                cockpit.isInitialized = true
                entity.components.set(cockpit)
            }
            
            // 2. Handle Control Scheme Toggles
            if let wheel = cockpit.steeringWheel {
                if wheel.isEnabled != cockpit.useSteeringWheel {
                    wheel.isEnabled = cockpit.useSteeringWheel
                }
            }
        }
    }
    
    private func animateIn(_ entity: Entity) {
        let from = Transform(scale: [0.001, 0.001, 0.001], rotation: entity.orientation, translation: entity.position)
        let to   = Transform(scale: entity.scale,  rotation: entity.orientation, translation: entity.position)
        
        if let anim = try? AnimationResource.generate(with: FromToByAnimation<Transform>(
            name: "build", from: from, to: to, duration: 1.5, timing: .easeInOut, bindTarget: .transform
        )) {
            entity.playAnimation(anim)
        }
    }
}
