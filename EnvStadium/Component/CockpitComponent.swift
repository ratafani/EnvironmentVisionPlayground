import RealityKit
import Foundation

struct CockpitComponent: Component {
    var useSteeringWheel: Bool
    
    // References to the sub-entities for the system to manage
    var leftThrottle: Entity?
    var rightThrottle: Entity?
    var steeringWheel: Entity?
    
    // Animation state
    var isInitialized: Bool = false
}
