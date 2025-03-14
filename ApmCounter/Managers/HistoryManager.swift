//Managers/HistoryManager.swift
import Foundation

class HistoryManager: ObservableObject {
    @Published var sessions: [SessionData] = []

    init() {
        loadSessions()
    }

    func loadSessions() {
        sessions = []
        let fileManager = FileManager.default
        do {
            let appSupportDir = try fileManager.url(for: .applicationSupportDirectory,
                                                    in: .userDomainMask,
                                                    appropriateFor: nil,
                                                    create: true)
            let logDirectory = appSupportDir.appendingPathComponent("ApmCounter/History", isDirectory: true)
            let files = try fileManager.contentsOfDirectory(at: logDirectory, includingPropertiesForKeys: nil)
            for file in files where file.pathExtension == "json" {
                let data = try Data(contentsOf: file)
                let session = try JSONDecoder().decode(SessionData.self, from: data)
                sessions.append(session)
            }
            sessions.sort { $0.sessionStart > $1.sessionStart }
        } catch {
            print("Error loading sessions: \(error)")
        }
    }

    func deleteSession(_ session: SessionData) {
        let fileManager = FileManager.default
        do {
            let appSupportDir = try fileManager.url(for: .applicationSupportDirectory,
                                                    in: .userDomainMask,
                                                    appropriateFor: nil,
                                                    create: true)
            let logDirectory = appSupportDir.appendingPathComponent("ApmCounter/History", isDirectory: true)
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd_HHmmss"
            let fileName = "Session_\(formatter.string(from: session.sessionStart)).json"
            let fileURL = logDirectory.appendingPathComponent(fileName)

            if fileManager.fileExists(atPath: fileURL.path) {
                try fileManager.removeItem(at: fileURL)
                loadSessions()
            }
        } catch {
            print("Error deleting session: \(error)")
        }
    }
}
