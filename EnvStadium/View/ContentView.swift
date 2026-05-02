//
//  ContentView.swift
//  EnvStadium
//
//  Created by Muhammad Tafani Rabbani on 30/04/26.
//

import SwiftUI
import RealityKit

struct ContentView: View {
    @Environment(AppModel.self) private var appModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Text("Flying Car Dashboard")
                    .font(.extraLargeTitle)
                
                HStack(spacing: 40) {
                    VStack {
                        Text("Speed")
                            .font(.title2)
                        Text(String(format: "%.1f", appModel.vehicleSpeed))
                            .font(.system(size: 40, weight: .bold))
                            .monospacedDigit()
                    }
                    
                    VStack {
                        Text("Steering")
                            .font(.title2)
                        Text(String(format: "%.1f°", appModel.steeringAngle * (180.0 / .pi)))
                            .font(.system(size: 40, weight: .bold))
                            .monospacedDigit()
                    }
                }
                .padding()
                .glassBackgroundEffect()

                ToggleImmersiveSpaceButton()
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Label("Settings", systemImage: "gearshape")
                    }
                }
            }
            .alert("Simulation Notice", isPresented: Binding(
                get: { appModel.showErrorAlert },
                set: { appModel.showErrorAlert = $0 }
            )) {
                Button("OK", role: .cancel) { }
            } message: {
                if let message = appModel.errorMessage {
                    Text(message)
                }
            }
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppModel())
}
