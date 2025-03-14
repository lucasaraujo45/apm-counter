//Managers/HotkeyManager.swift
import Cocoa
import Carbon

class HotkeyManager {
    static let shared = HotkeyManager()

    private var startPauseHotKeyRef: EventHotKeyRef?
    private var stopHotKeyRef: EventHotKeyRef?

    private init() {
        reloadHotkeys()
    }

    func reloadHotkeys() {
        unregisterAllHotkeys()

        let defaults = UserDefaults.standard
        if let startPauseKey = defaults.string(forKey: "startPauseHotkey"), !startPauseKey.isEmpty {
            registerHotkey(hotkey: startPauseKey, id: 1)
        }
        if let stopKey = defaults.string(forKey: "stopHotkey"), !stopKey.isEmpty {
            registerHotkey(hotkey: stopKey, id: 2)
        }
    }

    private func registerHotkey(hotkey: String, id: UInt32) {
        guard let keyCode = keyCode(from: hotkey) else { return }
        let modifiers = modifiersFlags(from: hotkey)
        var hotKeyRef: EventHotKeyRef?

        let hotKeyID = EventHotKeyID(signature: OSType("APMC".fourCharCodeValue), id: id)
        RegisterEventHotKey(keyCode, modifiers, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef)

        InstallEventHandler(GetApplicationEventTarget(), { (_, theEvent, _) -> OSStatus in
            var eventHotKeyID = EventHotKeyID()
            GetEventParameter(theEvent,
                              EventParamName(kEventParamDirectObject),
                              EventParamType(typeEventHotKeyID),
                              nil,
                              MemoryLayout<EventHotKeyID>.size,
                              nil,
                              &eventHotKeyID)

            DispatchQueue.main.async {
                let sessionManager = SessionManager.shared
                if eventHotKeyID.id == 1 {
                    sessionManager.toggleStartPause()
                } else if eventHotKeyID.id == 2 {
                    sessionManager.stopSession()
                }
            }
            return noErr
        }, 1, [EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))], nil, nil)

        if id == 1 { startPauseHotKeyRef = hotKeyRef }
        if id == 2 { stopHotKeyRef = hotKeyRef }
    }

    private func unregisterAllHotkeys() {
        if let hk = startPauseHotKeyRef { UnregisterEventHotKey(hk) }
        if let hk = stopHotKeyRef { UnregisterEventHotKey(hk) }
    }

    private func modifiersFlags(from hotkey: String) -> UInt32 {
        var mods: UInt32 = 0
        if hotkey.contains("⌘") { mods |= UInt32(cmdKey) }
        if hotkey.contains("⇧") { mods |= UInt32(shiftKey) }
        if hotkey.contains("⌥") { mods |= UInt32(optionKey) }
        if hotkey.contains("⌃") { mods |= UInt32(controlKey) }
        return mods
    }

    private func keyCode(from hotkey: String) -> UInt32? {
        guard let last = hotkey.last else { return nil }
        return KeyCodes.codes[String(last).uppercased()]
    }
}

struct KeyCodes {
    static let codes: [String: UInt32] = [
        "A":0,"B":11,"C":8,"D":2,"E":14,"F":3,"G":5,"H":4,
        "I":34,"J":38,"K":40,"L":37,"M":46,"N":45,"O":31,"P":35,
        "Q":12,"R":15,"S":1,"T":17,"U":32,"V":9,"W":13,"X":7,
        "Y":16,"Z":6,"0":29,"1":18,"2":19,"3":20,"4":21,
        "5":23,"6":22,"7":26,"8":28,"9":25
    ]
}

extension String {
    var fourCharCodeValue: FourCharCode {
        var result: FourCharCode = 0
        if let data = self.data(using: .macOSRoman), data.count == 4 {
            for byte in data {
                result = (result << 8) + FourCharCode(byte)
            }
        }
        return result
    }
}
