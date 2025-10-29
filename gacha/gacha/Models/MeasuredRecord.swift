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

    @Transient
    var ROM: Double? {
        guard let flexion = flexionAngle else { return nil }
        return flexion - extensionAngle
    }

    var measuredSeconds: Int?
    var painLevel: Int?

    init(extensionAngle: Double, flexionAngle: Double? = nil, measuredSeconds: Int? = nil, painLevel: Int? = nil) {
        self.id = UUID()
        self.measuredDate = Date.now
        self.extensionAngle = extensionAngle
        self.flexionAngle = flexionAngle
        self.measuredSeconds = measuredSeconds
        self.painLevel = painLevel
    }
}
