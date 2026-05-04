import RealityKit
import Foundation

struct VehicleInteractionSystem: System {
    static let handQuery    = EntityQuery(where: .has(HandTrackingComponent.self))
    static let controlQuery = EntityQuery(where: .has(InteractableControlComponent.self))
    static let cockpitQuery = EntityQuery(where: .has(CockpitComponent.self))
    static let serviceQuery = EntityQuery(where: .has(AppModelServiceComponent.self))
    
    private let interpreter: InteractionInterpreter = StandardInteractionInterpreter()
    
    init(scene: RealityKit.Scene) {}
    
    func update(context: SceneUpdateContext) {
        guard let serviceEntity = context.entities(matching: Self.serviceQuery, updatingSystemWhen: .rendering).first(where: { _ in true }),
              let appModel = serviceEntity.components[AppModelServiceComponent.self]?.appModel else {
            return
        }
        
        let hands = context.entities(matching: Self.handQuery, updatingSystemWhen: .rendering)
        let controls = context.entities(matching: Self.controlQuery, updatingSystemWhen: .rendering)
        let cockpit = context.entities(matching: Self.cockpitQuery, updatingSystemWhen: .rendering).first(where: { _ in true })
        
        let result = interpreter.interpret(hands: Array(hands), controls: Array(controls), cockpit: cockpit, config: .shared)
        
        // Update AppModel state
        appModel.leftThrottleInput = result.leftThrottle
        appModel.rightThrottleInput = result.rightThrottle
        
        if appModel.useSteeringWheel {
            appModel.steeringInput = MathUtilities.clamp(result.steering * 1.5, min: -1.2, max: 1.2)
        } else {
            // Tank drive mode steering
            let diff = result.leftThrottle - result.rightThrottle
            if abs(diff) > SimulationConfig.shared.tankDriveSteeringDeadzone {
                appModel.steeringInput = diff * 0.8
            } else {
                appModel.steeringInput = 0
            }
        }
    }
}
