import RealityKit
import RealityKitContent

/// A centralized service for loading and caching 3D resources.
@MainActor
class ResourceService {
    static let shared = ResourceService()
    
    private var cache: [String: Entity] = [:]
    
    /// Loads an entity by name, checking the main bundle and the RealityKitContent bundle.
    func loadEntity(named name: String) async throws -> Entity {
        if let cached = cache[name] {
            return cached.clone(recursive: true)
        }
        
        // Strategy: Try main bundle first, then RealityKitContent
        if let entity = try? await Entity(named: name) {
            cache[name] = entity
            return entity.clone(recursive: true)
        }
        
        if let entity = try? await Entity(named: name, in: realityKitContentBundle) {
            cache[name] = entity
            return entity.clone(recursive: true)
        }
        
        throw ResourceError.notFound(name)
    }
}

enum ResourceError: Error {
    case notFound(String)
}
