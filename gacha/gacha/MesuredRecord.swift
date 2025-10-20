//
//  DatabaseManager.swift
//  gacha
//
//  Created by Oh Seojin on 10/20/25.
//

import Foundation
import SwiftData

@Model
class MeasuredRecord: Identifiable {
    var id = UUID()
    var date = Date()
    var minAngle: Int
    var maxAngle: Int
    var isDeleted: Bool
    var image_id: String

    init(minAngle: Int, maxAngle: Int, isDeleted: Bool, image_id: String) {
        self.minAngle = minAngle
        self.maxAngle = maxAngle
        self.isDeleted = isDeleted
        self.image_id = image_id
    }
}
