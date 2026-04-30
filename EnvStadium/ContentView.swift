//
//  ContentView.swift
//  EnvStadium
//
//  Created by Muhammad Tafani Rabbani on 30/04/26.
//

import SwiftUI
import RealityKit

struct ContentView: View {

    var body: some View {
        VStack {
            ToggleImmersiveSpaceButton()
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppModel())
}
