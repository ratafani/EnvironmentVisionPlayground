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
    static let serviceQuery = EntityQuery(where: .has(AppModelServiceComponent.self))

    init(scene: RealityKit.Scene) {}

    func update(context: SceneUpdateContext) {
        let dt = Float(context.deltaTime)
        let hands    = context.entities(matching: Self.handQuery,    updatingSystemWhen: .rendering)
        let controls = context.entities(matching: Self.controlQuery, updatingSystemWhen: .rendering)
        let vehicles = context.entities(matching: Self.vehicleQuery, updatingSystemWhen: .rendering)
        
        // Find the injected AppModel
        guard let serviceEntity = context.entities(matching: Self.serviceQuery, updatingSystemWhen: .rendering).first(where: { _ in true }),
              let appModel = serviceEntity.components[AppModelServiceComponent.self]?.appModel else {
            return 
        }

        // 1. Natural Hand Tracking Logic
        for control in controls {
            for hand in hands {
                guard let hc = hand.components[HandTrackingComponent.self], hc.isGrabbing else { continue }
                
                let dist = simd_distance(hc.palmPosition, control.position(relativeTo: nil))
                guard dist < 0.15 else { continue } // Only if hand is close to the control

                if control.name == "SteeringWheel" {
                    let localPos = control.convert(position: hc.palmPosition, from: nil)
                    let angle = atan2(localPos.y, localPos.x)
                    control.orientation = simd_quatf(angle: angle, axis: [0, 0, 1])
                    appModel.steeringInput = MathUtilities.clamp(angle * 1.5, min: -1.2, max: 1.2)
                    
                } else if control.name.contains("ThrottleController") {
                    let localPos = control.convert(position: hc.palmPosition, from: nil)
                    let input = MathUtilities.clamp(localPos.z * 5.0, min: -0.6, max: 0.6) / 0.6
                    control.orientation = simd_quatf(angle: input * 0.6, axis: [1, 0, 0])
                    
                    if control.name.contains("001") { appModel.leftThrottleInput = input }
                    else { appModel.rightThrottleInput = input }
                    
                    let avgInput = (appModel.leftThrottleInput + appModel.rightThrottleInput) / 2.0
                    appModel.vehicleSpeed = 20.0 * avgInput * appModel.throttleSensitivity
                    
                    if !appModel.useSteeringWheel {
                        appModel.steeringInput = (appModel.leftThrottleInput - appModel.rightThrottleInput) * 0.8
                    }
                }
            }
        }

        // 2. Vehicle Physics Logic
        for vehicle in vehicles {
            guard var vc = vehicle.components[VehicleComponent.self] else { continue }

            let steer = appModel.steeringInput
            vc.headingAngle += -steer * 0.8 * appModel.steeringSensitivity * dt
            vc.bankAngle     = MathUtilities.lerp(from: vc.bankAngle, to: -steer * 0.25, t: dt * 3.0)

            vehicle.orientation = simd_quatf(angle: Float(vc.headingAngle), axis: [0, 1, 0])
                                 * simd_quatf(angle: Float(vc.bankAngle),    axis: [0, 0, 1])

            vc.speed = MathUtilities.lerp(from: vc.speed, to: appModel.vehicleSpeed, t: dt * 3.0)
            let forward = vehicle.transform.matrix.columns.2.xyz
            vehicle.position += forward * vc.speed * dt

            vehicle.components.set(vc)
            
            Task { @MainActor in appModel.steeringAngle = steer }
        }
    }
}

extension SIMD4 {
    var xyz: SIMD3<Scalar> { SIMD3(x, y, z) }
}
