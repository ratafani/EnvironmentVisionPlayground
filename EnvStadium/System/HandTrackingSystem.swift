//
//  HandTrackingSystem.swift
//  EnvStadium
//
//  Created by Muhammad Tafani Rabbani on 30/04/26.
//

import RealityKit
import ARKit

struct HandTrackingSystem: System {
    static var arSession     = ARKitSession()
    static let handTracking  = HandTrackingProvider()
    static var latestLeftHand:  HandAnchor?
    static var latestRightHand: HandAnchor?
    static var appModel: AppModel?

    static let query = EntityQuery(where: .has(HandTrackingComponent.self))

    init(scene: RealityKit.Scene) {
        Task { await Self.runSession() }
    }

    @MainActor
    static func runSession() async {
        // won't work on simulator, just show alert and bail
        guard HandTrackingProvider.isSupported else {
            appModel?.errorMessage = "Hand tracking not supported here (expected in Simulator)."
            appModel?.showErrorAlert = true
            return
        }

        do {
            try await arSession.run([handTracking])
        } catch {
            appModel?.errorMessage = "ARKit failed: \(error.localizedDescription)"
            appModel?.showErrorAlert = true
            return
        }

        for await update in handTracking.anchorUpdates {
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

            hc.isGrabbing    = GrabGestureDetector.isGrabbing(skeleton: skeleton)
            hc.wristPosition = HandPoseUtilities.worldPosition(of: .wrist, handAnchor: anchor, skeleton: skeleton)
            hc.palmPosition  = HandPoseUtilities.worldPosition(of: .middleFingerKnuckle, handAnchor: anchor, skeleton: skeleton)

            entity.components.set(hc)
        }
    }
}
