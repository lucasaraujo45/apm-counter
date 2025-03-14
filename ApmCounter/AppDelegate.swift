import Cocoa
import ApplicationServices

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Check Accessibility permissions
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        let isTrusted = AXIsProcessTrustedWithOptions(options)
        if !isTrusted {
            print("The app is not yet trusted for Accessibility. "
                  + "Please enable it in System Settings > Privacy & Security > Accessibility.")
        }
        
        // Register global hotkeys (loaded from user defaults)
        HotkeyManager.shared.reloadHotkeys()
    }
}
