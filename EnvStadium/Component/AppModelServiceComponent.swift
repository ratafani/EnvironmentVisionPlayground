import RealityKit

/// A service component that injects the AppModel into the RealityKit world.
/// This allows Systems to access the global state without relying on singletons.
struct AppModelServiceComponent: Component {
    var appModel: AppModel
}
