import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
    @Environment(AppModel.self) var appModel
    @State private var viewModel: ImmersiveViewModel
    
    init(level: LevelConfig? = nil) {
        _viewModel = State(initialValue: ImmersiveViewModel(level: level ?? StadiumLevel()))
    }

    var body: some View {
        RealityView { content in
            viewModel.appModel = appModel
            await viewModel.setupEnvironment(into: content)
        }
        .onChange(of: appModel.useSteeringWheel) { _, newValue in
            if var comp = viewModel.cockpit?.components[CockpitComponent.self] {
                comp.useSteeringWheel = newValue
                viewModel.cockpit?.components.set(comp)
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .targetedToAnyEntity()
                .onChanged { viewModel.handleDragChanged($0) }
                .onEnded { viewModel.handleDragEnded($0) }
        )
    }
}

#Preview(immersionStyle: .full) {
    ImmersiveView()
        .environment(AppModel())
}
