import RealityKit
import SwiftUI

/// A system that renders visual cues for hand tracking and grab detection.
struct DebugHandVisualSystem: System {
    static let query = EntityQuery(where: .has(HandTrackingComponent.self))
    
    private let sphereMesh = MeshResource.generateSphere(radius: 0.02)
    private let trackedMaterial = SimpleMaterial(color: .yellow, isMetallic: false)
    private let grabbingMaterial = SimpleMaterial(color: .green, isMetallic: false)
    private let interactingMaterial = SimpleMaterial(color: .cyan, isMetallic: true)
    
    init(scene: RealityKit.Scene) {}
    
    func update(context: SceneUpdateContext) {
        let entities = context.entities(matching: Self.query, updatingSystemWhen: .rendering)
        
        for entity in entities {
            guard let hc = entity.components[HandTrackingComponent.self] else { continue }
            
            // 1. Ensure the entity has a debug visual
            var debugEntity: Entity
            if let existing = entity.findEntity(named: "PalmDebugSphere") {
                debugEntity = existing
            } else {
                debugEntity = ModelEntity(mesh: sphereMesh, materials: [trackedMaterial])
                debugEntity.name = "PalmDebugSphere"
                entity.addChild(debugEntity)
            }
            
            // 2. Position the sphere at the palm
            debugEntity.position = hc.palmPosition
            
            
            // 3. Check for proximity to controls
            let controls = context.entities(matching: EntityQuery(where: .has(InteractableControlComponent.self)), updatingSystemWhen: .rendering)
            let isNearControl = controls.contains { simd_distance(hc.palmPosition, $0.position(relativeTo: nil)) < 0.25 }
            
            // 4. Update material and scale based on state
            if let model = debugEntity as? ModelEntity {
                var material = hc.isGrabbing ? grabbingMaterial : trackedMaterial
                if isNearControl {
                    material = interactingMaterial
                    debugEntity.scale = [1.5, 1.5, 1.5]
                } else {
                    debugEntity.scale = [1.0, 1.0, 1.0]
                }
                model.model?.materials = [material]
            }
        }
    }
}
