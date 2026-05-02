//
//  ReferenceObjectSpawner.swift
//  EnvStadium
//
//  Created by Muhammad Tafani Rabbani on 30/04/26.
//

import RealityKit
import UIKit

// adds clouds & buoys to the world so u can feel speed via parallax
enum ReferenceObjectSpawner {

    static func spawnObjects(in worldRoot: Entity) {
        spawnClouds(in: worldRoot)
        spawnBuoys(in: worldRoot)
    }

    private static func spawnClouds(in root: Entity) {
        let positions: [SIMD3<Float>] = [
            [ 4,  5,  -8], [-5,  4, -10], [ 3,  6, -15],
            [-6,  5, -12], [ 8,  7, -20], [-3,  5, -18],
            [ 15,  6, -30], [-20,  7, -25], [ 10,  5, -35],
            [-12,  6, -40], [ 25,  8, -45], [-18,  5, -50],
            [ 20,  5,  -5], [-25,  6,  -8], [ 30,  7,   5],
            [-30,  5,  10], [ 18,  4, -60], [-22,  6, -55],
        ]

        for (i, pos) in positions.enumerated() {
            let cloud = makeCloud(index: i)
            cloud.position = pos
            root.addChild(cloud)
        }
    }

    private static func makeCloud(index: Int) -> Entity {
        let root = Entity()
        root.name = "Cloud_\(index)"

        // a few overlapping spheres = looks like a cloud
        for _ in 0..<Int.random(in: 2...4) {
            let puff = ModelEntity(
                mesh: .generateSphere(radius: Float.random(in: 0.8...2.0)),
                materials: [UnlitMaterial(color: UIColor.white.withAlphaComponent(0.85))]
            )
            puff.position = [
                Float.random(in: -1.5...1.5),
                Float.random(in: -0.3...0.3),
                Float.random(in: -1.0...1.0)
            ]
            root.addChild(puff)
        }

        return root
    }

    private static func spawnBuoys(in root: Entity) {
        let positions: [SIMD3<Float>] = [
            [  3, 0,  -6], [ -4, 0,  -8], [  5, 0, -12],
            [ -3, 0, -15], [  7, 0, -20], [ -8, 0, -18],
            [ 12, 0, -30], [-15, 0, -25], [ 10, 0, -40],
            [-10, 0, -35], [ 20, 0, -50], [-18, 0, -45],
        ]

        let colors: [UIColor] = [.systemOrange, .systemYellow, .systemRed, .cyan]

        for (i, pos) in positions.enumerated() {
            let buoy = makeBuoy(color: colors[i % colors.count])
            buoy.position = pos
            root.addChild(buoy)
        }
    }

    private static func makeBuoy(color: UIColor) -> Entity {
        let root = Entity()

        let pole = ModelEntity(
            mesh: .generateCylinder(height: 1.5, radius: 0.04),
            materials: [UnlitMaterial(color: .gray)]
        )
        pole.position = [0, 0.75, 0]
        root.addChild(pole)

        let ball = ModelEntity(
            mesh: .generateSphere(radius: 0.2),
            materials: [UnlitMaterial(color: color)]
        )
        ball.position = [0, 1.6, 0]
        root.addChild(ball)

        return root
    }
}
