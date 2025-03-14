// Views/HistoryView.swift
import SwiftUI

struct HistoryView: View {
    @StateObject var historyManager = HistoryManager()
    
    var body: some View {
        VStack(alignment: .leading) {
            if historyManager.sessions.isEmpty {
                Text("No history available.")
                    .foregroundColor(.gray)
                    .padding()
                Spacer()
            } else {
                List(historyManager.sessions, id: \.sessionStart) { session in
                    HistoryRow(session: session)
                }
            }
        }
        .padding()
    }
}

struct HistoryRow: View {
    let session: SessionData
    var body: some View {
        VStack(alignment: .leading) {
            Text("Session: \(formattedDate(session.sessionStart))")
                .font(.headline)
            HStack {
                Text("Total Actions: \(formatNumber(session.totalActions))")
                Spacer()
                Text("Duration: \(formattedDuration(session.totalTime))")
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .padding(4)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formattedDuration(_ seconds: Int) -> String {
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

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
            .frame(width: 300, height: 500)
    }
}
