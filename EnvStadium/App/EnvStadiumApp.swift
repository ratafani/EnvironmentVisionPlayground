//
//  EnvStadiumApp.swift
//  EnvStadium
//
//  Created by Muhammad Tafani Rabbani on 30/04/26.
//

import SwiftUI
import RealityKit


@main
struct EnvStadiumApp: App {
    
    @State private var appModel = AppModel()
    @State private var avPlayerViewModel = AVPlayerViewModel()
    
    init() {
        // Register Components
        VehicleComponent.registerComponent()
        InteractableControlComponent.registerComponent()
        HandTrackingComponent.registerComponent()
        CockpitComponent.registerComponent()
        AppModelServiceComponent.registerComponent()
        
        // Register Systems
        HandTrackingSystem.registerSystem()
        VehicleInteractionSystem.registerSystem()
        VehiclePhysicsSystem.registerSystem()
        CockpitVisualSystem.registerSystem()
        CockpitSystem.registerSystem()
        DebugHandVisualSystem.registerSystem()
        HandDebugSystem.registerSystem()
    }
    
    var body: some SwiftUI.Scene {
        WindowGroup(id: "main") {
            if avPlayerViewModel.isPlaying {
                AVPlayerView(viewModel: avPlayerViewModel)
            } else {
                ContentView()
                    .environment(appModel)
            }
        }
        
        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(appModel)
                .onAppear {
                    avPlayerViewModel.play()
                }
                .onDisappear {
                    avPlayerViewModel.reset()
                }
        }
        .immersionStyle(selection: .constant(.full), in: .full)
        
        WindowGroup(id: appModel.debugWindowID) {
            HandDebugView()
                .environment(appModel)
        }
        .defaultSize(width: 500, height: 600)
    }
}
