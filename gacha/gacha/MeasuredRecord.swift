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
    @Attribute(.unique) var id: UUID
    var date: Date
    var flexionAngle: Int
    var extensionAngle: Int
    var isDeleted: Bool
    var flexionImage_id: String
    var extensionImage_id: String

    init(flexionAngle: Int, extensionAngle: Int, isDeleted: Bool, flexionImage_id: String, extensionImage_id: String) {
        self.id = UUID()
        self.date = Date()
        self.flexionAngle = flexionAngle
        self.extensionAngle = extensionAngle
        self.isDeleted = isDeleted
        self.flexionImage_id = flexionImage_id
        self.extensionImage_id = extensionImage_id
    }
}
