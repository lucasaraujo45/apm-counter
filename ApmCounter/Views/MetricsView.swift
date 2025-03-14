// Views/MetricsView.swift
import SwiftUI

struct MetricsView: View {
    @ObservedObject var sessionManager: SessionManager
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Current APM: \(sessionManager.currentAPM)")
                Spacer()
                Text("Highest APM: \(sessionManager.highestAPM)")
            }
            HStack {
                Text("Average APM: \(sessionManager.averageAPM)")
                Spacer()
                Text("Total Actions: \(formatNumber(sessionManager.totalActions))")
            }
            HStack {
                Text("Active Time: \(formatTime(sessionManager.activeTime))")
                Spacer()
                Text("Inactive: \(formatTime(sessionManager.inactiveTime))")
            }
        }
        .font(.system(size: 14, weight: .medium, design: .default))
        .padding()
        .frame(width: 400, height: 90)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(NSColor.controlBackgroundColor)))
        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
    }
    
    private func formatTime(_ seconds: Int) -> String {
        if seconds < 3600 {
            let minutes = seconds / 60
            return "\(minutes)m"
        } else {
            let hours = seconds / 3600
            let minutes = (seconds % 3600) / 60
            return "\(hours)h \(minutes)m"
        }
    }
    
    private func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}

struct MetricsView_Previews: PreviewProvider {
    static var previews: some View {
        MetricsView(sessionManager: SessionManager.shared)
    }
}
