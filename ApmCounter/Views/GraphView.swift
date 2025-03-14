// Views/GraphView.swift
import SwiftUI

struct GraphView: View {
    @ObservedObject var sessionManager: SessionManager
    @State private var viewMode: GraphViewMode = .minute
    
    enum GraphViewMode { case minute, hour }
    
    private static let timeFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "h:mma"
        df.amSymbol = "am"
        df.pmSymbol = "pm"
        return df
    }()
    
    var body: some View {
        VStack(spacing: 8) {
            Picker("", selection: $viewMode) {
                Text("Minute").tag(GraphViewMode.minute)
                Text("Hour").tag(GraphViewMode.hour)
            }
            .pickerStyle(SegmentedPickerStyle())
            .frame(maxWidth: 300)
            GeometryReader { geometry in
                ZStack {
                    drawGrid(in: geometry)
                    drawLine(in: geometry)
                    drawDots(in: geometry)
                }
            }
        }
    }
    
    private func drawGrid(in geometry: GeometryProxy) -> some View {
        let data = currentData()
        let maxValue = max(data.max() ?? 0, 1)
        let doubleMax = Double(maxValue)
        return ForEach(0...4, id: \.self) { i in
            gridLine(for: i, doubleMax: doubleMax, geometry: geometry)
        }
    }
    
    private func gridLine(for i: Int, doubleMax: Double, geometry: GeometryProxy) -> some View {
        let lineValue = doubleMax * Double(i) / 4.0
        let yPos = geometry.size.height * (1 - CGFloat(lineValue / doubleMax))
        return ZStack(alignment: .leading) {
            Path { path in
                path.move(to: CGPoint(x: 30, y: yPos))
                path.addLine(to: CGPoint(x: geometry.size.width, y: yPos))
            }
            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            Text("\(Int(lineValue))")
                .font(.system(size: 8))
                .foregroundColor(.gray)
                .position(x: 15, y: yPos)
        }
    }
    
    private func drawLine(in geometry: GeometryProxy) -> some View {
        let data = currentData()
        let maxValue = max(data.max() ?? 0, 1)
        return Path { path in
            for (index, value) in data.enumerated() {
                let x = xPosition(index: index, totalPoints: data.count, width: geometry.size.width)
                let y = geometry.size.height * (1 - CGFloat(value) / CGFloat(maxValue))
                if index == 0 { path.move(to: CGPoint(x: x, y: y)) }
                else { path.addLine(to: CGPoint(x: x, y: y)) }
            }
        }
        .stroke(Color.blue, lineWidth: 2)
    }
    
    private func drawDots(in geometry: GeometryProxy) -> some View {
        let data = currentData()
        let timestamps = currentTimestamps()
        let maxValue = max(data.max() ?? 0, 1)
        return ForEach(data.indices, id: \.self) { index in
            let value = data[index]
            let x = xPosition(index: index, totalPoints: data.count, width: geometry.size.width)
            let y = geometry.size.height * (1 - CGFloat(value) / CGFloat(maxValue))
            let dateString: String = index < timestamps.count ? GraphView.timeFormatter.string(from: timestamps[index]) : "N/A"
            return Circle()
                .fill(Color.blue)
                .frame(width: 4, height: 4)
                .position(x: x, y: y)
                .help(Text("APM: \(value)\nTime: \(dateString)"))
        }
    }
    
    private func xPosition(index: Int, totalPoints: Int, width: CGFloat) -> CGFloat {
        let usableWidth = width - 30
        return 30 + usableWidth * CGFloat(index) / CGFloat(max(totalPoints - 1, 1))
    }
    
    private func currentData() -> [Int] {
        switch viewMode {
        case .minute: return sessionManager.apmData
        case .hour: return sessionManager.hourlyAverageData
        }
    }
    
    private func currentTimestamps() -> [Date] {
        switch viewMode {
        case .minute: return sessionManager.apmTimestamps
        case .hour: return sessionManager.hourlyAverageTimestamps
        }
    }
}

struct GraphView_Previews: PreviewProvider {
    static var previews: some View {
        GraphView(sessionManager: SessionManager())
            .frame(minWidth: 400, minHeight: 200)
    }
}
