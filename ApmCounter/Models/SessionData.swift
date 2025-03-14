//Models/SessionData.swift

import Foundation

struct SessionData: Codable {
    let sessionStart: Date
    let sessionEnd: Date
    let totalActions: Int
    let apmData: [Int]
    let averageAPM: Int
    let highestAPM: Int
    let activeTime: Int
    let inactiveTime: Int
    let totalTime: Int
}
