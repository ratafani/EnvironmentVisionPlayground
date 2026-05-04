//
//  GrabGestureDetector.swift
//  EnvStadium
//
//  Created by Muhammad Tafani Rabbani on 30/04/26.
//

import ARKit

// all fingers curled = grab
struct GrabGestureDetector {
    struct FingerStatus {
        let index: Bool
        let middle: Bool
        let ring: Bool
        let pinky: Bool
        let thumb: Bool
        
        var isGrabbing: Bool {
            // Relaxed logic: Thumb + Index + Middle is enough for a "grab"
            return thumb && index && middle
        }
    }

    static func getDetails(skeleton: HandSkeleton) -> FingerStatus {
        let index  = HandPoseUtilities.isFingerCurled(skeleton: skeleton, tip: .indexFingerTip,  knuckle: .indexFingerKnuckle)
        let middle = HandPoseUtilities.isFingerCurled(skeleton: skeleton, tip: .middleFingerTip, knuckle: .middleFingerKnuckle)
        let ring   = HandPoseUtilities.isFingerCurled(skeleton: skeleton, tip: .ringFingerTip,   knuckle: .ringFingerKnuckle)
        let pinky  = HandPoseUtilities.isFingerCurled(skeleton: skeleton, tip: .littleFingerTip, knuckle: .littleFingerKnuckle)
        let thumb  = HandPoseUtilities.isThumbCurled(skeleton: skeleton)
        
        return FingerStatus(index: index, middle: middle, ring: ring, pinky: pinky, thumb: thumb)
    }

    static func isGrabbing(skeleton: HandSkeleton) -> Bool {
        return getDetails(skeleton: skeleton).isGrabbing
    }
}
