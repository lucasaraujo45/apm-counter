//Views/SettingsView
import SwiftUI

enum AppearanceMode: String, CaseIterable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
}

struct SettingsView: View {
    @AppStorage("appearanceMode") private var appearanceMode: String = AppearanceMode.system.rawValue
    @AppStorage("startPauseHotkey") private var startPauseHotkey: String = ""
    @AppStorage("stopHotkey") private var stopHotkey: String = ""
    
    @State private var isRecordingStartPause: Bool = false
    @State private var isRecordingStop: Bool = false
    @State private var hotkeyMonitor: Any?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Appearance")
                .font(.headline)
            
            Picker("", selection: $appearanceMode) {
                ForEach(AppearanceMode.allCases, id: \.rawValue) { mode in
                    Text(mode.rawValue).tag(mode.rawValue)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .onChange(of: appearanceMode) { _, newValue in
                switch newValue {
                case AppearanceMode.system.rawValue: NSApp.appearance = nil
                case AppearanceMode.light.rawValue: NSApp.appearance = NSAppearance(named: .aqua)
                case AppearanceMode.dark.rawValue: NSApp.appearance = NSAppearance(named: .darkAqua)
                default: break
                }
            }
            
            Divider()
            
            Text("Hotkey Settings")
                .font(.headline)
            
            hotkeyRecorder("Start/Pause Hotkey:", currentHotkey: startPauseHotkey, isRecording: isRecordingStartPause) {
                startHotkeyRecording(isStartPause: true)
            }
            
            hotkeyRecorder("Stop Hotkey:", currentHotkey: stopHotkey, isRecording: isRecordingStop) {
                startHotkeyRecording(isStartPause: false)
            }
            
            Spacer()
        }
        .padding()
        .onDisappear {
            HotkeyManager.shared.reloadHotkeys()
        }
    }
    
    @ViewBuilder
    private func hotkeyRecorder(_ title: String, currentHotkey: String, isRecording: Bool, recordAction: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                Spacer()
                Text(currentHotkey.isEmpty ? "Not Set" : currentHotkey)
                    .foregroundColor(.secondary)
            }
            if isRecording {
                HStack(spacing: 4) {
                    Image(systemName: "record.circle")
                    Text("Recording… Press new hotkey")
                        .font(.subheadline)
                        .foregroundColor(.accentColor)
                }
            }
            Button(action: recordAction) {
                Text(isRecording ? "Cancel Recording" : "Record Hotkey")
            }
        }
    }
    
    private func startHotkeyRecording(isStartPause: Bool) {
        if isRecordingStartPause || isRecordingStop {
            stopRecording()
            return
        }
        
        if isStartPause {
            isRecordingStartPause = true
        } else {
            isRecordingStop = true
        }
        
        hotkeyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            let newHotkey = hotkeyString(for: event)
            
            // Prevent duplicate hotkeys
            if isStartPause && newHotkey == stopHotkey {
                stopHotkey = ""
            } else if !isStartPause && newHotkey == startPauseHotkey {
                startPauseHotkey = ""
            }
            
            if isStartPause {
                startPauseHotkey = newHotkey
                isRecordingStartPause = false
            } else {
                stopHotkey = newHotkey
                isRecordingStop = false
            }
            
            stopRecording()
            return nil
        }
    }
    
    private func stopRecording() {
        if let monitor = hotkeyMonitor {
            NSEvent.removeMonitor(monitor)
            hotkeyMonitor = nil
        }
        isRecordingStartPause = false
        isRecordingStop = false
    }
    
    private func hotkeyString(for event: NSEvent) -> String {
        var modifiers = ""
        if event.modifierFlags.contains(.command) { modifiers += "⌘" }
        if event.modifierFlags.contains(.shift) { modifiers += "⇧" }
        if event.modifierFlags.contains(.option) { modifiers += "⌥" }
        if event.modifierFlags.contains(.control) { modifiers += "⌃" }
        let key = event.charactersIgnoringModifiers?.uppercased() ?? ""
        return modifiers + key
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .frame(width: 300, height: 500)
    }
}
