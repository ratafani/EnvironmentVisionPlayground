//
//  GrabGestureDetector.swift
//  EnvStadium
//
//  Created by Muhammad Tafani Rabbani on 30/04/26.
//

import ARKit

// all fingers curled = grab
struct GrabGestureDetector {
    static func isGrabbing(skeleton: HandSkeleton) -> Bool {
        let index  = HandPoseUtilities.isFingerCurled(skeleton: skeleton, tip: .indexFingerTip,  knuckle: .indexFingerKnuckle)
        let middle = HandPoseUtilities.isFingerCurled(skeleton: skeleton, tip: .middleFingerTip, knuckle: .middleFingerKnuckle)
        let ring   = HandPoseUtilities.isFingerCurled(skeleton: skeleton, tip: .ringFingerTip,   knuckle: .ringFingerKnuckle)
        let pinky  = HandPoseUtilities.isFingerCurled(skeleton: skeleton, tip: .littleFingerTip, knuckle: .littleFingerKnuckle)
        let thumb  = HandPoseUtilities.isThumbCurled(skeleton: skeleton)

        return index && middle && ring && pinky && thumb
    }
}
