// Views/SettingsView.swift
import SwiftUI

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @State private var currentHotkey: String = "⌘⇧O"
    @State private var isRecordingHotkey: Bool = false
    @State private var hotkeyMonitor: Any?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Appearance")
                .font(.headline)
            Toggle("Dark Mode", isOn: $isDarkMode)
                .onChange(of: isDarkMode) { newValue in
                    NSApp.appearance = NSAppearance(named: newValue ? .darkAqua : .aqua)
                }
            Divider()
            Text("Hotkey Settings")
                .font(.headline)
            HStack {
                Text("Start/Stop Hotkey:")
                Spacer()
                Text(currentHotkey)
                    .foregroundColor(.secondary)
            }
            if isRecordingHotkey {
                Text("Recording... Press new hotkey")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            Button(action: { startRecording() }) {
                Text(isRecordingHotkey ? "Cancel Recording" : "Record Hotkey")
            }
            Spacer()
        }
        .padding()
    }
    
    private func startRecording() {
        if isRecordingHotkey {
            isRecordingHotkey = false
            if let monitor = hotkeyMonitor {
                NSEvent.removeMonitor(monitor)
                hotkeyMonitor = nil
            }
        } else {
            isRecordingHotkey = true
            hotkeyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                let newHotkey = hotkeyString(for: event)
                currentHotkey = newHotkey
                isRecordingHotkey = false
                if let monitor = hotkeyMonitor {
                    NSEvent.removeMonitor(monitor)
                    hotkeyMonitor = nil
                }
                // TODO: Update HotkeyManager with new hotkey configuration.
                return event
            }
        }
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
