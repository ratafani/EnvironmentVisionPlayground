//
//  SettingsView.swift
//  EnvStadium
//

import SwiftUI

struct SettingsView: View {
    @Environment(AppModel.self) private var appModel
    
    var body: some View {
        @Bindable var model = appModel
        
        Form {
            Section(header: Text("Control Scheme")) {
                Toggle("Use Virtual Steering Wheel", isOn: $model.useSteeringWheel)
            }
            
            Section(header: Text("Controls Sensitivity")) {
                VStack(alignment: .leading) {
                    Text("Steering Sensitivity: \(String(format: "%.1f", model.steeringSensitivity))")
                    Slider(value: $model.steeringSensitivity, in: 0.1...5.0, step: 0.1)
                }
                
                VStack(alignment: .leading) {
                    Text("Throttle Sensitivity: \(String(format: "%.1f", model.throttleSensitivity))")
                    Slider(value: $model.throttleSensitivity, in: 0.1...5.0, step: 0.1)
                }
            }
            
            Section(footer: Text("Adjust these settings to change how reactive the virtual steering wheel and power stick are to your hand movements.")) {}
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environment(AppModel())
    }
}
