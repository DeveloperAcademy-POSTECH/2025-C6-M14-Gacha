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
    var flexionAngle: Double?

    @Transient
    var ROM: Double? {
        return flexionAngle
    }

    var measuredSeconds: Int?
    var painLevel: Int?

    init(flexionAngle: Double? = nil, measuredSeconds: Int? = nil, painLevel: Int? = nil) {
        self.id = UUID()
        self.measuredDate = Date.now
        self.flexionAngle = flexionAngle
        self.measuredSeconds = measuredSeconds
        self.painLevel = painLevel
    }
}
