//Models/EventMonitor.swift
import Cocoa

class EventMonitor {
    private var monitor: Any?
    private let eventHandler: () -> Void

    init(eventHandler: @escaping () -> Void) {
        self.eventHandler = eventHandler
    }
    
    func start() {
        stop()
        monitor = NSEvent.addGlobalMonitorForEvents(matching: [
            .keyDown,
            .leftMouseDown,
            .rightMouseDown
        ]) { [weak self] _ in
            self?.eventHandler()
        }
    }
    
    func stop() {
        if let monitor = monitor {
            NSEvent.removeMonitor(monitor)
            self.monitor = nil
        }
    }
    
    deinit {
        stop()
    }
}
