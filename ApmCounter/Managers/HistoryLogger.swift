//Managers/HistoryLogger
import Foundation

class HistoryLogger {
    static let shared = HistoryLogger()
    
    private init() {}
    
    func logSession(sessionData: SessionData) {
        let fileManager = FileManager.default
        do {
            // Locate (or create) the Application Support directory
            let appSupportDir = try fileManager.url(for: .applicationSupportDirectory,
                                                    in: .userDomainMask,
                                                    appropriateFor: nil,
                                                    create: true)
            
            let logDirectory = appSupportDir.appendingPathComponent("ApmCounter/History", isDirectory: true)
            if !fileManager.fileExists(atPath: logDirectory.path) {
                try fileManager.createDirectory(at: logDirectory,
                                                withIntermediateDirectories: true,
                                                attributes: nil)
            }
            
            // Use the session start time for a unique file name
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd_HHmmss"
            let fileName = "Session_\(formatter.string(from: sessionData.sessionStart)).json"
            let fileURL = logDirectory.appendingPathComponent(fileName)
            
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(sessionData)
            try data.write(to: fileURL)
            print("Session logged at \(fileURL.path)")
        } catch {
            print("Error logging session: \(error)")
        }
    }
}
