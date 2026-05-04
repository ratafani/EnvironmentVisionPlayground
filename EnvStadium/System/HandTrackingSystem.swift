import RealityKit
import ARKit

struct HandTrackingSystem: System {
    static var arSession     = ARKitSession()
    static let handTracking  = HandTrackingProvider()
    static var latestLeftHand:  HandAnchor?
    static var latestRightHand: HandAnchor?

    static let query = EntityQuery(where: .has(HandTrackingComponent.self))

    init(scene: RealityKit.Scene) {}

    @MainActor
    static func runSession(appModel: AppModel) async {
        guard HandTrackingProvider.isSupported else {
            appModel.errorMessage = "Hand tracking not supported here (expected in Simulator)."
            appModel.showErrorAlert = true
            return
        }

        do {
            print("ARKit: Starting hand tracking session...")
            try await arSession.run([handTracking])
            print("ARKit: Hand tracking session running.")
        } catch {
            print("ARKit Error: \(error)")
            appModel.errorMessage = "ARKit failed: \(error.localizedDescription)"
            appModel.showErrorAlert = true
            return
        }

        for await update in handTracking.anchorUpdates {
            print("ARKit: Hand update received for \(update.anchor.chirality)")
            switch update.anchor.chirality {
            case .left:  latestLeftHand  = update.anchor
            case .right: latestRightHand = update.anchor
            }
        }
    }

    func update(context: SceneUpdateContext) {
        let entities = context.entities(matching: Self.query, updatingSystemWhen: .rendering)

        for entity in entities {
            guard var hc = entity.components[HandTrackingComponent.self] else { continue }
            let anchor = hc.chirality == .left ? Self.latestLeftHand : Self.latestRightHand
            guard let anchor, let skeleton = anchor.handSkeleton else { continue }

            let details = GrabGestureDetector.getDetails(skeleton: skeleton)
            hc.wristPosition = HandPoseUtilities.worldPosition(of: .wrist, handAnchor: anchor, skeleton: skeleton)
            hc.palmPosition  = HandPoseUtilities.worldPosition(of: .middleFingerKnuckle, handAnchor: anchor, skeleton: skeleton)

            // Anti-jitter logic for Grab
            if details.isGrabbing {
                hc.grabFrameCount = min(hc.grabFrameCount + 1, 10)
            } else {
                hc.grabFrameCount = max(hc.grabFrameCount - 1, 0)
            }
            
            let wasGrabbing = hc.isGrabbingFiltered
            if hc.grabFrameCount >= 3 {
                hc.isGrabbingFiltered = true
            } else if hc.grabFrameCount == 0 {
                hc.isGrabbingFiltered = false
            }
            
            hc.isGrabbing = hc.isGrabbingFiltered
            
            // Populate finger states for debugging
            hc.thumbCurled  = details.thumb
            hc.indexCurled  = details.index
            hc.middleCurled = details.middle
            hc.ringCurled   = details.ring
            hc.pinkyCurled  = details.pinky

            // Relative Grab Position Logic
            if hc.isGrabbingFiltered {
                if !wasGrabbing || hc.initialGrabPosition == nil {
                    hc.initialGrabPosition = hc.palmPosition
                }
            } else {
                hc.initialGrabPosition = nil
            }

            entity.components.set(hc)
        }
    }
}
