//
//  ImmersiveView.swift
//  EnvStadium
//
//  Created by Muhammad Tafani Rabbani on 30/04/26.
//

import SwiftUI
import RealityKit
import RealityKitContent
import ARKit

struct ImmersiveView: View {
    @Environment(AppModel.self) var appModel

    var body: some View {
        RealityView { content in
            VehicleControlSystem.appModel = appModel
            HandTrackingSystem.appModel = appModel

            // visionOS origin = floor. eye level ≈ 1.6m up, dashboard sits ~1.3m
            let cockpit = CockpitEntity()
            cockpit.position = [0, 1.3, -0.6]
            content.add(cockpit)
            cockpit.animateIn()

            // world moves, not u — that's how flying feels
            let worldRoot = Entity()
            worldRoot.name = "FlyingCar"
            worldRoot.components.set(VehicleComponent())
            content.add(worldRoot)

            if let env = try? await Entity(named: "Immersive", in: realityKitContentBundle) {
                worldRoot.addChild(env)
            }

            // clouds & buoys so u can feel the speed
            ReferenceObjectSpawner.spawnObjects(in: worldRoot)

            // hand tracking entities
            let leftHand = Entity()
            leftHand.components.set(HandTrackingComponent(chirality: .left))
            content.add(leftHand)

            let rightHand = Entity()
            rightHand.components.set(HandTrackingComponent(chirality: .right))
            content.add(rightHand)
        }
        // simulator only: hold stick = gas, drag wheel = steer
        .gesture(
            DragGesture(minimumDistance: 0)
                .targetedToAnyEntity()
                .onChanged { value in
                    let name = value.entity.name

                    if name == "PowerStick" {
                        appModel.vehicleSpeed = 2.0 * appModel.throttleSensitivity
                    }

                    if name == "SteeringWheel" {
                        let drag = Float(value.gestureValue.translation.width)
                        appModel.steeringInput = MathUtilities.clamp(
                            drag / 80.0 * appModel.steeringSensitivity,
                            min: -1.0, max: 1.0
                        )
                    }
                }
                .onEnded { value in
                    let name = value.entity.name
                    if name == "PowerStick"    { appModel.vehicleSpeed  = 0.0 }
                    if name == "SteeringWheel" { appModel.steeringInput = 0.0 }
                }
        )
    }
}

#Preview(immersionStyle: .full) {
    ImmersiveView()
        .environment(AppModel())
}
