import RealityKit
import Foundation
import ARKit

struct HandDebugSystem: System {
    static let handQuery    = EntityQuery(where: .has(HandTrackingComponent.self))
    static let controlQuery = EntityQuery(where: .has(InteractableControlComponent.self))
    static let serviceQuery = EntityQuery(where: .has(AppModelServiceComponent.self))
    
    init(scene: RealityKit.Scene) {}
    
    func update(context: SceneUpdateContext) {
        guard let serviceEntity = context.entities(matching: Self.serviceQuery, updatingSystemWhen: .rendering).first(where: { _ in true }),
              let appModel = serviceEntity.components[AppModelServiceComponent.self]?.appModel else {
            return
        }
        
        let hands = context.entities(matching: Self.handQuery, updatingSystemWhen: .rendering)
        let controls = context.entities(matching: Self.controlQuery, updatingSystemWhen: .rendering)
        
        for hand in hands {
            guard let hc = hand.components[HandTrackingComponent.self] else { continue }
            
            // This is purely for the debug window
            var debugInfo = AppModel.HandDebugInfo(
                isTracked: true,
                isGrabbing: hc.isGrabbing,
                indexCurled: hc.indexCurled,
                middleCurled: hc.middleCurled,
                ringCurled: hc.ringCurled,
                pinkyCurled: hc.pinkyCurled,
                thumbCurled: hc.thumbCurled
            )
            
            // Logic to find nearest control name and distance for UI
            var minDist: Float = .infinity
            var nearestName: String? = nil
            var nearestControl: Entity? = nil
            
            for control in controls {
                let d = simd_distance(hc.palmPosition, control.position(relativeTo: nil))
                if d < minDist {
                    minDist = d
                    nearestName = control.name
                    nearestControl = control
                }
            }
            
            if minDist < 5.0 {
                debugInfo.nearestControlName = nearestName
                debugInfo.nearestControlDistance = minDist
                debugInfo.localPosition = nearestControl?.convert(position: hc.palmPosition, from: nil)
            }
            
            Task { @MainActor in
                if hc.chirality == .left {
                    appModel.leftHandDebug = debugInfo
                } else {
                    appModel.rightHandDebug = debugInfo
                }
            }
        }
    }
}
