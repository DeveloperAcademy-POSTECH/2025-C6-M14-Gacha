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
    var measuredDate: Date
    var extensionAngle: Double
    var flexionAngle: Double?
    // flexionAngle과 extensionAngle의 차이를 계산하여 ROM을 계산할 수 있지 않나?
    //var ROM: Double = 0.0

    public var ROM: Double? {
        guard let flexion = flexionAngle else { return nil }
        return extensionAngle - flexion
    }

    var measuredMinutes: Int?
    var painLevel: Double?

    init(extensionAngle: Double) {
        self.measuredDate = Date.now
        self.extensionAngle = extensionAngle
        self.flexionAngle = nil
        self.measuredMinutes = nil
        self.painLevel = nil
    }
}
