//
//  CockpitEntity.swift
//  EnvStadium
//
//  Created by Muhammad Tafani Rabbani on 30/04/26.
//

import RealityKit
import SwiftUI
import RealityKitContent

class CockpitEntity: Entity {
    
    private var leftThrottle: Entity?
    private var rightThrottle: Entity?
    private var steeringWheel: Entity?
    
    @MainActor
    required init() {
        super.init()
        self.name = "Cockpit"
        setupRealAsset()
    }
    
    @MainActor
    convenience init(useSteeringWheel: Bool) {
        self.init()
        updateControlScheme(useSteeringWheel: useSteeringWheel)
    }
    
    private func setupRealAsset() {
        let assetNames = ["cockpit", "cockpit.usdc"]
        let asset = assetNames.compactMap { try? Entity.load(named: $0) }.first ?? 
                    (try? Entity.load(named: "cockpit", in: realityKitContentBundle))
        
        guard let asset else { return }
        self.addChild(asset)
        
        // Map controls
        leftThrottle = asset.findEntity(named: "ThrottleController_001") ?? asset.findEntity(named: "ThrottleController.001")
        rightThrottle = asset.findEntity(named: "ThrottleController_002") ?? asset.findEntity(named: "ThrottleController.002")
        
        setupLighting()
        
        for throttle in [leftThrottle, rightThrottle].compactMap({ $0 }) {
            throttle.components.set(InputTargetComponent())
            let shape = ShapeResource.generateSphere(radius: 0.15)
            var collision = CollisionComponent(shapes: [shape], isStatic: true)
            collision.filter = CollisionFilter(group: .all, mask: .all)
            throttle.components.set(collision)
            throttle.components.set(InteractableControlComponent(controlType: .power))
        }
    }

    private func setupLighting() {
        let lamp = Entity()
        lamp.components.set(PointLightComponent(color: .white, attenuationRadius: 100))
        lamp.position = [0, 1.5, -0.45]
        self.addChild(lamp)
    }

    func updateControlScheme(useSteeringWheel: Bool) {
        if useSteeringWheel {
            if steeringWheel == nil {
                setupProceduralSteeringWheel()
            }
            steeringWheel?.isEnabled = true
        } else {
            steeringWheel?.isEnabled = false
        }
    }
    
    private func setupProceduralSteeringWheel() {
        // Simple procedural wheel using a thin Cylinder
        let wheel = ModelEntity(mesh: .generateCylinder(height: 0.02, radius: 0.12), 
                                materials: [SimpleMaterial(color: .black, isMetallic: true)])
        wheel.name = "SteeringWheel"
        // Position it right in front of the driver, above the dashboard
        wheel.position = [0, 0.7, -0.45]
        // Tilt it towards the user (X-axis)
        wheel.orientation = simd_quatf(angle: .pi/2.5, axis: [1, 0, 0]) 
        
        wheel.components.set(InputTargetComponent())
        wheel.components.set(CollisionComponent(shapes: [.generateSphere(radius: 0.15)]))
        wheel.components.set(InteractableControlComponent(controlType: .steering))
        
        self.addChild(wheel)
        self.steeringWheel = wheel
    }
    
    // scales up from 0 when u enter the space
    func animateIn() {
        let from = Transform(scale: [0.001, 0.001, 0.001], rotation: self.orientation, translation: self.position)
        let to   = Transform(scale: .one,  rotation: self.orientation, translation: self.position)
        
        let anim = FromToByAnimation<Transform>(
            name: "build",
            from: from, to: to,
            duration: 1.5,
            timing: .easeInOut,
            bindTarget: .transform
        )
        
        guard let resource = try? AnimationResource.generate(with: anim) else {
            self.scale = .one
            return
        }
        
        self.scale = .zero
        self.playAnimation(resource)
    }
}
