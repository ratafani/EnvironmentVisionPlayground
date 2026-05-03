import SwiftUI
import RealityKit
import RealityKitContent
import ARKit

@MainActor
@Observable
class ImmersiveViewModel: VehicleControlHandling {
    var appModel: AppModel?
    var cockpit: Entity?
    var currentLevel: LevelConfig
    
    init(appModel: AppModel? = nil, level: LevelConfig = StadiumLevel()) {
        self.appModel = appModel
        self.currentLevel = level
    }
    
    // MARK: - Environment Setup
    func setupEnvironment(into content: RealityViewContent) async {
        guard let appModel else { return }
        
        // Start Hand Tracking Session
        Task { await HandTrackingSystem.runSession(appModel: appModel) }
        
        // Build Cockpit
        let cockpit = await CockpitFactory.create(useSteeringWheel: appModel.useSteeringWheel)
        cockpit.position = [0, 0.4, 0]
        content.add(cockpit)
        self.cockpit = cockpit
        
        // Build World based on Current Level
        let worldRoot = Entity()
        worldRoot.name = "FlyingCar"
        worldRoot.components.set(VehicleComponent())
        worldRoot.components.set(AppModelServiceComponent(appModel: appModel))
        content.add(worldRoot)
        
        if let env = try? await ResourceService.shared.loadEntity(named: currentLevel.environmentAssetName) {
            worldRoot.addChild(env)
        }
        
        ReferenceObjectSpawner.spawnObjects(in: worldRoot)
        setupHands(into: content)
    }
    
    private func setupHands(into content: RealityViewContent) {
        let leftHand = Entity()
        leftHand.components.set(HandTrackingComponent(chirality: .left))
        content.add(leftHand)

        let rightHand = Entity()
        rightHand.components.set(HandTrackingComponent(chirality: .right))
        content.add(rightHand)
    }
    
    // MARK: - Gesture Handling
    func handleDragChanged(_ value: EntityTargetValue<DragGesture.Value>) {
        let name = value.entity.name
        if name.contains("ThrottleController") {
            updateThrottle(value.entity, translation: Float(value.gestureValue.translation.height))
        } else if name == "SteeringWheel" {
            updateSteering(value.entity, translation: Float(value.gestureValue.translation.width))
        }
    }
    
    func handleDragEnded(_ value: EntityTargetValue<DragGesture.Value>) {
        guard let appModel else { return }
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
    
    // MARK: - Internal Helpers
    private func updateThrottle(_ entity: Entity, translation: Float) {
        guard let appModel, !translation.isNaN else { return }
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
        guard let appModel else { return }
        let rotation = MathUtilities.clamp(translation * 0.01, min: -1.2, max: 1.2)
        entity.orientation = simd_quatf(angle: -rotation, axis: [0, 0, 1])
        appModel.steeringInput = rotation * appModel.steeringSensitivity
    }
}
