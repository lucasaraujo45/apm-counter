// ContentView.swift
import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @StateObject var sessionManager = SessionManager.shared

    
    var body: some View {
        VStack(spacing: 0) {
            Picker("", selection: $selectedTab) {
                Text("Track").tag(0)
                Text("Settings").tag(1)
                Text("History").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            Divider()
            
            Group {
                if selectedTab == 0 {
                    TrackView(sessionManager: sessionManager)
                } else if selectedTab == 1 {
                    SettingsView()
                } else {
                    HistoryView()
                }
            }
            .frame(width: 400, height: 500) // Keep consistent content size across tabs
        }
    }
}

struct TrackView: View {
    @ObservedObject var sessionManager: SessionManager
    var body: some View {
        VStack(spacing: 16) {
            MetricsView(sessionManager: sessionManager)
            ControlsView(sessionManager: sessionManager)
            GraphView(sessionManager: sessionManager)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
