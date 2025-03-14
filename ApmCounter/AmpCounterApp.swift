import SwiftUI

@main
struct AmpCounterApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .background(WindowAccessor { window in
                    window.level = .floating
                    window.isOpaque = true
                    window.title = "AmpCounter"
                    window.styleMask.remove(.resizable) // Prevent resizing
                    window.standardWindowButton(.zoomButton)?.isEnabled = false
                })
                .fixedSize() // Forces exact content size
        }
        .windowResizability(.contentSize) // limits window to exact content size
    }
}
