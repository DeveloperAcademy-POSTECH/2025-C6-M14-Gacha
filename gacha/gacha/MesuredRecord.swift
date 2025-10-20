//
//  DatabaseManager.swift
//  gacha
//
//  Created by Oh Seojin on 10/20/25.
//

import Foundation
import SwiftData

@Model
class MesuredRecord: Identifiable {
    @Attribute(.unique) var id: UUID
    var date: Date
    var flexionAngle: Int
    var extensionAngle: Int
    var isDeleted: Bool
    var image_id: String

    init(flexionAngle: Int, extensionAngle: Int, isDeleted: Bool, image_id: String) {
        self.id = UUID()
        self.date = Date()
        self.flexionAngle = flexionAngle
        self.extensionAngle = extensionAngle
        self.isDeleted = isDeleted
        self.image_id = image_id
    }
}
