// HistoryView.swift

import SwiftUI

struct HistoryView: View {
    @StateObject var historyManager = HistoryManager()
    @State private var selectedSession: SessionData?

    var body: some View {
        VStack(alignment: .leading) {
            if historyManager.sessions.isEmpty {
                Text("No history available.")
                    .foregroundColor(.gray)
                    .padding()
                Spacer()
            } else {
                List {
                    ForEach(historyManager.sessions, id: \.sessionStart) { session in
                        Button(action: { selectedSession = session }) {
                            HistoryRow(session: session, deleteAction: {
                                deleteSession(session)
                            })
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .sheet(item: $selectedSession) { session in
                    SessionDetailView(session: session)
                }
            }
        }
        .padding()
    }

    private func deleteSession(_ session: SessionData) {
        withAnimation {
            historyManager.deleteSession(session)
        }
    }
}

struct HistoryRow: View {
    let session: SessionData
    let deleteAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Session: \(formattedDate(session.sessionStart))")
                .font(.headline)
            HStack {
                VStack(alignment: .leading) {
                    Text("Total Actions: \(formatNumber(session.totalActions))")
                    Text("Average APM: \(session.averageAPM)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text("Duration: \(formattedDuration(session.totalTime))")
                    .foregroundColor(.secondary)
                
                Button(action: deleteAction) {
                    Image(systemName: "trash")
                        .foregroundColor(.red.opacity(0.7))
                        .padding(.leading, 6)
                }
                .buttonStyle(BorderlessButtonStyle())
                .help("Delete session")
            }
            .font(.subheadline)
        }
        .padding(.vertical, 4)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func formattedDuration(_ seconds: Int) -> String {
        let minutes = (seconds % 3600) / 60
        let hours = seconds / 3600
        return hours > 0 ? "\(hours)h \(minutes)m" : "\(minutes)m"
    }

    private func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}

struct SessionDetailView: View {
    let session: SessionData
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Text("Session Details")
                .font(.largeTitle)
                .padding(.top)

            VStack(alignment: .leading, spacing: 10) {
                detailRow(label: "Start Time", value: formattedDate(session.sessionStart))
                detailRow(label: "End Time", value: formattedDate(session.sessionEnd))
                detailRow(label: "Total Duration", value: formattedDuration(session.totalTime))
                detailRow(label: "Total Actions", value: formatNumber(session.totalActions))
                detailRow(label: "Average APM", value: "\(session.averageAPM)")
                detailRow(label: "Highest APM", value: "\(session.highestAPM)")
                detailRow(label: "Active Time", value: formattedDuration(session.activeTime))
                detailRow(label: "Inactive Time", value: formattedDuration(session.inactiveTime))
            }
            .padding()

            Spacer()

            Button("Close") {
                dismiss()
            }
            .keyboardShortcut(.cancelAction)
            .padding(.bottom)
        }
        .frame(width: 400)
    }

    private func detailRow(label: String, value: String) -> some View {
        HStack {
            Text(label).bold()
            Spacer()
            Text(value).foregroundColor(.secondary)
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func formattedDuration(_ seconds: Int) -> String {
        let minutes = (seconds % 3600) / 60
        let hours = seconds / 3600
        return hours > 0 ? "\(hours)h \(minutes)m" : "\(minutes)m"
    }

    private func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}

extension SessionData: Identifiable {
    var id: Date { sessionStart }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView().frame(width: 400, height: 500)
    }
}
