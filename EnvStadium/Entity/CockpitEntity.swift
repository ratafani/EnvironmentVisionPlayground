//
//  CockpitEntity.swift
//  EnvStadium
//
//  Created by Muhammad Tafani Rabbani on 30/04/26.
//

import RealityKit
import SwiftUI

class CockpitEntity: Entity {

    private var dashboard: ModelEntity?
    private var steeringWheel: ModelEntity?
    private var powerStick: ModelEntity?

    @MainActor
    required init() {
        super.init()
        self.name = "Cockpit"
        buildDashboard()
        buildWheel()
        buildStick()
    }

    private func buildDashboard() {
        let d = ModelEntity(
            mesh: .generateBox(size: [0.8, 0.2, 0.1], cornerRadius: 0.05),
            materials: [UnlitMaterial(color: .darkGray)]
        )
        d.position = [0, 0, 0]
        self.addChild(d)
        self.dashboard = d
    }

    private func buildWheel() {
        guard let dashboard else { return }
        let wheel = ModelEntity(
            mesh: .generateCylinder(height: 0.02, radius: 0.15),
            materials: [UnlitMaterial(color: .black)]
        )
        wheel.name = "SteeringWheel"
        wheel.position = [0, 0.15, 0.05]
        wheel.orientation = simd_quatf(angle: .pi / 2, axis: [1, 0, 0])
        wheel.components.set(InteractableControlComponent(controlType: .steering))
        wheel.components.set(InputTargetComponent())
        wheel.components.set(CollisionComponent(shapes: [.generateBox(size: [0.32, 0.32, 0.04])]))
        dashboard.addChild(wheel)
        self.steeringWheel = wheel
    }

    private func buildStick() {
        guard let dashboard else { return }
        let stick = ModelEntity(
            mesh: .generateCylinder(height: 0.2, radius: 0.04),
            materials: [UnlitMaterial(color: .red)]
        )
        stick.name = "PowerStick"
        stick.position = [0.3, 0.1, 0.05]
        stick.components.set(InteractableControlComponent(controlType: .power))
        stick.components.set(InputTargetComponent())
        stick.components.set(CollisionComponent(shapes: [.generateCapsule(height: 0.2, radius: 0.04)]))
        dashboard.addChild(stick)
        self.powerStick = stick
    }

    // scales up from 0 when u enter the space
    func animateIn() {
        let from = Transform(scale: .zero, rotation: self.orientation, translation: self.position)
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
