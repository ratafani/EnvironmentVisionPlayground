import RealityKit
import simd

struct StandardInteractionInterpreter: InteractionInterpreter {
    func interpret(hands: [Entity], controls: [Entity], cockpit: Entity?, config: SimulationConfig) -> (leftThrottle: Float, rightThrottle: Float, steering: Float) {
        var leftThrottle: Float = 0
        var rightThrottle: Float = 0
        var steering: Float = 0
        
        for hand in hands {
            guard let hc = hand.components[HandTrackingComponent.self], hc.isGrabbing else { continue }
            
            // 1. Check for steering wheel interaction
            if let steeringWheel = controls.first(where: { $0.name == "SteeringWheel" }) {
                let dist = simd_distance(hc.palmPosition, steeringWheel.position(relativeTo: nil))
                if dist < config.interactionRange {
                    let localPos = steeringWheel.convert(position: hc.palmPosition, from: nil)
                    steering = atan2(localPos.y, localPos.x)
                    continue
                }
            }
            
            // 2. Throttle Logic (Direct/Relative)
            if let cockpit = cockpit {
                let localHandPos = cockpit.convert(position: hc.palmPosition, from: nil)
                
                var throttleInput: Float = 0
                if let startPos = hc.initialGrabPosition {
                    let localStartPos = cockpit.convert(position: startPos, from: nil)
                    let deltaZ = localHandPos.z - localStartPos.z
                    throttleInput = MathUtilities.clamp(-deltaZ * config.relativeGrabSensitivity, min: -1.0, max: 1.0)
                }
                
                if localHandPos.x < 0 {
                    leftThrottle = throttleInput
                } else {
                    rightThrottle = throttleInput
                }
            }
        }
        
        return (leftThrottle, rightThrottle, steering)
    }
}
