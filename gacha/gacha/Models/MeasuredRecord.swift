//
//  MeasuredRecord.swift
//  gacha
//
//  Created by 차원준 on 10/23/25.
//
import SwiftData
import Foundation

@Model
class MeasuredRecord {
    var id: UUID
    var measuredDate: Date
    var extensionAngle: Double
    var flexionAngle: Double?

    public var ROM: Double? {
        guard let flexion = flexionAngle else { return nil }
        return flexion - extensionAngle
    }

    var measuredSeconds: Int?
    var painLevel: Int?

    init(extensionAngle: Double) {
        self.id = UUID()
        self.measuredDate = Date.now
        self.extensionAngle = extensionAngle
        self.flexionAngle = nil
        self.measuredSeconds = nil
        self.painLevel = nil
    }
}
