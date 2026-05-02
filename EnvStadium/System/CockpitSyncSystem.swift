//
//  CockpitSyncSystem.swift
//  EnvStadium
//
//  Created by Muhammad Tafani Rabbani on 30/04/26.
//

import RealityKit

// runs every frame — copies world POSITION from the head guide to the cockpit
// rotation is NOT copied, so u can look around inside freely
struct CockpitSyncSystem: System {
    init(scene: RealityKit.Scene) {}

    func update(context: SceneUpdateContext) {
        guard let guide   = context.scene.findEntity(named: "CockpitGuide"),
              let cockpit = context.scene.findEntity(named: "Cockpit") else { return }

        cockpit.setPosition(guide.position(relativeTo: nil), relativeTo: nil)
    }
}
