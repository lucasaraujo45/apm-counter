// Managers/SessionManager.swift
import Foundation

class SessionManager: ObservableObject {
    static let shared = SessionManager()
    
    @Published var currentAPM: Int = 0
    @Published var averageAPM: Int = 0
    @Published var highestAPM: Int = 0
    @Published var activeTime: Int = 0
    @Published var inactiveTime: Int = 0
    @Published var totalTime: Int = 0
    @Published var totalActions: Int = 0

    @Published var apmData: [Int] = []
    @Published var apmTimestamps: [Date] = []
    @Published var hourlyAverageData: [Int] = []
    @Published var hourlyAverageTimestamps: [Date] = []

    @Published var isRunning: Bool = false
    @Published var isPaused: Bool = false

    private var timer: Timer?
    private var secondTimer: Timer?
    private var sessionStart: Date?
    private var sessionEnd: Date?

    private var eventsInCurrentMinute: Int = 0
    private var minuteStart: Date?

    private var lastActionTime: Date?

    private var eventMonitor: EventMonitor?
    let inactivityThreshold: TimeInterval = 30

    private init() {
        eventMonitor = EventMonitor(eventHandler: { [weak self] in
            self?.recordAction()
        })
    }

    func toggleStartPause() {
        if !isRunning {
            startSession()
        } else {
            isPaused.toggle()
            if isPaused {
                pauseSession()
            } else {
                resumeSession()
            }
        }
    }

    func startSession() {
        resetSession()
        isRunning = true
        isPaused = false
        sessionStart = Date()
        minuteStart = Date()
        lastActionTime = Date()
        eventsInCurrentMinute = 0
        startTimers()
        eventMonitor?.start()
    }

    func pauseSession() {
        eventMonitor?.stop()
    }

    func resumeSession() {
        lastActionTime = Date()
        eventMonitor?.start()
    }

    func stopSession() {
        guard isRunning else { return }
        isRunning = false
        isPaused = false
        stopTimers()
        eventMonitor?.stop()
        sessionEnd = Date()
        updateMinuteMetrics()
        HistoryLogger.shared.logSession(sessionData: createSessionData())
    }

    private func resetSession() {
        currentAPM = 0
        averageAPM = 0
        highestAPM = 0
        activeTime = 0
        inactiveTime = 0
        totalTime = 0
        totalActions = 0

        apmData = []
        apmTimestamps = []

        hourlyAverageData = []
        hourlyAverageTimestamps = []
    }

    private func startTimers() {
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.updateMinuteMetrics()
        }

        secondTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateTimeMetrics()
        }
    }

    private func stopTimers() {
        timer?.invalidate()
        secondTimer?.invalidate()
    }

    private func updateMinuteMetrics() {
        currentAPM = eventsInCurrentMinute
        apmData.append(currentAPM)
        apmTimestamps.append(Date())

        highestAPM = max(highestAPM, currentAPM)

        if apmData.count % 60 == 0 {
            let lastHourData = apmData.suffix(60)
            let hourAverage = lastHourData.reduce(0, +) / 60
            hourlyAverageData.append(hourAverage)
            hourlyAverageTimestamps.append(Date())
        }

        eventsInCurrentMinute = 0
        minuteStart = Date()
    }

    private func updateTimeMetrics() {
        guard let start = sessionStart else { return }
        totalTime = Int(Date().timeIntervalSince(start))

        if let last = lastActionTime {
            let interval = Date().timeIntervalSince(last)
            if interval >= inactivityThreshold {
                inactiveTime += 1
            } else {
                activeTime += 1
            }
        }

        let sessionDurationMinutes = Double(totalTime) / 60.0
        averageAPM = sessionDurationMinutes > 0 ? Int(Double(totalActions) / sessionDurationMinutes) : 0
    }

    func recordAction() {
        guard isRunning, !isPaused else { return }
        eventsInCurrentMinute += 1
        totalActions += 1
        lastActionTime = Date()
    }

    private func createSessionData() -> SessionData {
        SessionData(
            sessionStart: sessionStart ?? Date(),
            sessionEnd: sessionEnd ?? Date(),
            totalActions: apmData.reduce(0, +),
            apmData: apmData,
            averageAPM: averageAPM,
            highestAPM: highestAPM,
            activeTime: activeTime,
            inactiveTime: inactiveTime,
            totalTime: totalTime
        )
    }
}
