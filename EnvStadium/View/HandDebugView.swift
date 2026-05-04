import SwiftUI

struct HandDebugView: View {
    @Environment(AppModel.self) var appModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Hand Tracking Debug")
                .font(.title)
                .bold()
            
            HStack(spacing: 40) {
                handInfoView(title: "Left Hand", info: appModel.leftHandDebug)
                handInfoView(title: "Right Hand", info: appModel.rightHandDebug)
            }
            
            Divider()
            
            VStack(alignment: .leading) {
                Text("Grab Logic: Thumb && Index && Middle").font(.caption).foregroundStyle(.secondary)
                Text("Distance Threshold: 0.15m").font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(width: 500)
    }
    
    @ViewBuilder
    func handInfoView(title: String, info: AppModel.HandDebugInfo) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.headline)
            
            HStack {
                Text("Tracked:")
                statusCircle(info.isTracked)
            }
            
            HStack {
                Text("Is Grabbing:")
                statusCircle(info.isGrabbing, activeColor: .green)
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text("Fingers:").font(.subheadline).bold()
                fingerRow("Thumb", info.thumbCurled)
                fingerRow("Index", info.indexCurled)
                fingerRow("Middle", info.middleCurled)
                fingerRow("Ring", info.ringCurled)
                fingerRow("Pinky", info.pinkyCurled)
            }
            .padding(.leading, 10)
            
            if let name = info.nearestControlName, let dist = info.nearestControlDistance {
                VStack(alignment: .leading) {
                    Text("Nearest: \(name)").font(.caption).bold()
                    Text(String(format: "Dist: %.3fm", dist))
                        .font(.caption2)
                        .foregroundStyle(dist < 0.15 ? .green : .primary)
                    
                    if let local = info.localPosition {
                        Text(String(format: "Local: X:%.2f Y:%.2f Z:%.2f", local.x, local.y, local.z))
                            .font(.system(size: 8, weight: .light))
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(5)
                .background(dist < 0.15 ? Color.green.opacity(0.1) : Color.clear)
                .cornerRadius(6)
            }
        }
        .padding()
        .background(.thinMaterial)
        .cornerRadius(12)
    }
    
    @ViewBuilder
    func fingerRow(_ name: String, _ isCurled: Bool) -> some View {
        HStack {
            Text(name).frame(width: 60, alignment: .leading)
            Text(isCurled ? "CURLED" : "OPEN")
                .font(.caption2)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(isCurled ? Color.blue.opacity(0.3) : Color.gray.opacity(0.2))
                .cornerRadius(4)
            statusCircle(isCurled, activeColor: .blue)
        }
    }
    
    @ViewBuilder
    func statusCircle(_ isActive: Bool, activeColor: Color = .green) -> some View {
        Circle()
            .fill(isActive ? activeColor : Color.gray.opacity(0.3))
            .frame(width: 12, height: 12)
    }
}

#Preview {
    HandDebugView()
        .environment(AppModel())
}
