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
    @State private var cockpit: CockpitEntity?

    var body: some View {
        RealityView { content in
            VehicleControlSystem.appModel = appModel
            HandTrackingSystem.appModel = appModel

            // visionOS origin = floor. eye level ≈ 1.6m up
            let cockpit = CockpitEntity(useSteeringWheel: appModel.useSteeringWheel)
            cockpit.position = [0, 0.4, 0]
            content.add(cockpit)
            cockpit.animateIn()
            self.cockpit = cockpit

            // world moves, not u
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
        .onChange(of: appModel.useSteeringWheel) { _, newValue in
            cockpit?.updateControlScheme(useSteeringWheel: newValue)
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .targetedToAnyEntity()
                .onChanged { handleGesture($0) }
                .onEnded { resetControls($0) }
        )
    }

    private func handleGesture(_ value: EntityTargetValue<DragGesture.Value>) {
        let name = value.entity.name
        
        if name.contains("ThrottleController") {
            updateThrottle(value.entity, translation: Float(value.gestureValue.translation.height))
        } else if name == "SteeringWheel" {
            updateSteering(value.entity, translation: Float(value.gestureValue.translation.width))
        }
    }

    private func updateThrottle(_ entity: Entity, translation: Float) {
        guard !translation.isNaN else { return }
        let input = MathUtilities.clamp(-translation * 0.005, min: -0.6, max: 0.6) / 0.6
        
        if entity.name.contains("001") { appModel.leftThrottleInput = input } 
        else { appModel.rightThrottleInput = input }

        entity.orientation = simd_quatf(angle: input * 0.6, axis: [1, 0, 0])
        
        let avgInput = (appModel.leftThrottleInput + appModel.rightThrottleInput) / 2.0
        appModel.vehicleSpeed = 20.0 * avgInput * appModel.throttleSensitivity
        
        if !appModel.useSteeringWheel {
            appModel.steeringInput = (appModel.leftThrottleInput - appModel.rightThrottleInput) * 0.8
        }
    }

    private func updateSteering(_ entity: Entity, translation: Float) {
        let rotation = MathUtilities.clamp(translation * 0.01, min: -1.2, max: 1.2)
        entity.orientation = simd_quatf(angle: -rotation, axis: [0, 0, 1])
        appModel.steeringInput = rotation * appModel.steeringSensitivity
    }

    private func resetControls(_ value: EntityTargetValue<DragGesture.Value>) {
        value.entity.orientation = .init()
        if value.entity.name.contains("ThrottleController") {
            if value.entity.name.contains("001") { appModel.leftThrottleInput = 0 }
            else { appModel.rightThrottleInput = 0 }
            appModel.vehicleSpeed = 0
            if !appModel.useSteeringWheel { appModel.steeringInput = 0 }
        } else {
            appModel.steeringInput = 0
        }
    }
}

#Preview(immersionStyle: .full) {
    ImmersiveView()
        .environment(AppModel())
}
