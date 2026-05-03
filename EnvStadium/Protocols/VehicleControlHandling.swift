import RealityKit
import SwiftUI

/// Defines the contract for any system that handles vehicle inputs in the immersive space.
@MainActor
protocol VehicleControlHandling: Observable {
    var appModel: AppModel? { get set }
    var cockpit: Entity? { get set }
    
    func handleDragChanged(_ value: EntityTargetValue<DragGesture.Value>)
    func handleDragEnded(_ value: EntityTargetValue<DragGesture.Value>)
    func setupEnvironment(into content: RealityViewContent) async
}
