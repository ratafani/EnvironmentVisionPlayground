//
//  VehicleControlSystem.swift
//  EnvStadium
//
//  Created by Muhammad Tafani Rabbani on 30/04/26.
//

import RealityKit
import Foundation

struct VehicleControlSystem: System {
    static let vehicleQuery = EntityQuery(where: .has(VehicleComponent.self))
    static let controlQuery = EntityQuery(where: .has(InteractableControlComponent.self))
    static let handQuery    = EntityQuery(where: .has(HandTrackingComponent.self))

    static var appModel: AppModel?

    init(scene: RealityKit.Scene) {}

    func update(context: SceneUpdateContext) {
        let dt = Float(context.deltaTime)

        let hands    = context.entities(matching: Self.handQuery,    updatingSystemWhen: .rendering)
        let controls = context.entities(matching: Self.controlQuery, updatingSystemWhen: .rendering)
        let vehicles = context.entities(matching: Self.vehicleQuery, updatingSystemWhen: .rendering)

        guard let appModel = Self.appModel else { return }

        // hand grab → update physical controls (wheel & stick)
        for control in controls {
            guard var cc = control.components[InteractableControlComponent.self] else { continue }

            for hand in hands {
                guard let hc = hand.components[HandTrackingComponent.self], hc.isGrabbing else { continue }

                let dist = simd_distance(hc.palmPosition, control.position(relativeTo: nil))
                guard dist < 0.15 else { continue }

                if cc.controlType == .steering {
                    let offset = hc.palmPosition - control.position(relativeTo: nil)
                    let angle  = atan2(offset.y, offset.x)
                    cc.currentValue = angle
                    control.setOrientation(simd_quatf(angle: angle, axis: [0, 0, 1]), relativeTo: control.parent)
                } else if cc.controlType == .power {
                    let local    = control.convert(position: hc.palmPosition, from: nil)
                    let throttle = MathUtilities.clamp(local.z * 5.0, min: -1.0, max: 1.0)
                    cc.currentValue = throttle
                    control.setPosition([0, 0, throttle * 0.1], relativeTo: control.parent)
                }
            }

            control.components.set(cc)
        }

        // move the world based on steering + throttle input
        for vehicle in vehicles {
            guard var vc = vehicle.components[VehicleComponent.self] else { continue }

            // heading accumulates, bank lerps — rebuild orientation clean every frame
            let steer = appModel.steeringInput
            vc.headingAngle += -steer * 0.8 * appModel.steeringSensitivity * dt
            vc.bankAngle     = MathUtilities.lerp(from: vc.bankAngle, to: -steer * 0.25, t: dt * 3.0)

            vehicle.orientation = simd_quatf(angle: vc.headingAngle, axis: [0, 1, 0])
                                 * simd_quatf(angle: vc.bankAngle,    axis: [0, 0, 1])

            // world moves away from u = u feel flying forward
            vc.speed      = MathUtilities.lerp(from: vc.speed, to: appModel.vehicleSpeed, t: dt * 3.0)
            let forward   = vehicle.transform.matrix.columns.2.xyz
            vehicle.position += forward * vc.speed * dt

            vehicle.components.set(vc)

            Task { @MainActor in appModel.steeringAngle = steer }
        }

        // animate controls visually based on current input
        animateControls(controls: controls, appModel: appModel, dt: dt)
    }

    // stick tilts forward when throttle is on, snaps back when released
    // wheel rotates left/right with steering input
    private func animateControls(controls: some Sequence<Entity>, appModel: AppModel, dt: Float) {
        for control in controls {
            guard let cc = control.components[InteractableControlComponent.self] else { continue }

            if cc.controlType == .power {
                // tilt forward up to ~25° when throttle active, snap back when not
                let targetTilt: Float = appModel.vehicleSpeed > 0 ? -0.45 : 0.0
                let currentTilt = atan2(
                    control.orientation.imag.x,
                    control.orientation.real
                ) * 2.0
                let newTilt = MathUtilities.lerp(from: currentTilt, to: targetTilt, t: dt * 8.0)
                control.orientation = simd_quatf(angle: newTilt, axis: [1, 0, 0])

            } else if cc.controlType == .steering {
                // base orientation is flat disc (pi/2 on X), add Z rotation for steering
                let steer = appModel.steeringInput
                let baseQ  = simd_quatf(angle: .pi / 2, axis: [1, 0, 0])
                let turnQ  = simd_quatf(angle: steer * 0.6, axis: [0, 0, 1]) // max ~34° turn
                let target = baseQ * turnQ

                // lerp from current to target
                control.orientation = simd_slerp(control.orientation, target, dt * 8.0)
            }
        }
    }
}

extension SIMD4 {
    var xyz: SIMD3<Scalar> { SIMD3(x, y, z) }
}
