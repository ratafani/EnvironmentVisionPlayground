import Foundation

/// Defines the assets and metadata for a specific simulation environment.
protocol LevelConfig {
    var id: String { get }
    var name: String { get }
    var environmentAssetName: String { get }
    var initialVehicleSpeed: Float { get }
}

/// The current Stadium environment.
struct StadiumLevel: LevelConfig {
    let id = "stadium"
    let name = "EnvStadium"
    let environmentAssetName = "Immersive"
    let initialVehicleSpeed: Float = 0.0
}

/// Example of a future level (Placeholder).
struct MarsLevel: LevelConfig {
    let id = "mars"
    let name = "Red Planet"
    let environmentAssetName = "MarsSurface"
    let initialVehicleSpeed: Float = 5.0
}
