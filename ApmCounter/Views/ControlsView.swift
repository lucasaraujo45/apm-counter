// Views/ControlsView.swift
import SwiftUI

struct ControlsView: View {
    @ObservedObject var sessionManager: SessionManager
    var body: some View {
        HStack(spacing: 16) {
            Button(action: { sessionManager.toggleStartPause() }) {
                Text(sessionManager.isRunning ? (sessionManager.isPaused ? "Resume" : "Pause") : "Start")
                    .frame(minWidth: 80)
            }
            .buttonStyle(BlueButtonStyle())
            
            Button(action: { sessionManager.stopSession() }) {
                Text("Stop")
                    .frame(minWidth: 80)
            }
            .buttonStyle(BlueButtonStyle())
            .disabled(!sessionManager.isRunning)
        }
        .padding(.horizontal)
        .frame(height: 40)
    }
}

struct BlueButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .medium))
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(Color.accentColor.opacity(configuration.isPressed ? 0.7 : 1.0))
            .foregroundColor(.white)
            .cornerRadius(8)
    }
}

struct ControlsView_Previews: PreviewProvider {
    static var previews: some View {
        ControlsView(sessionManager: SessionManager.shared)
    }
}
