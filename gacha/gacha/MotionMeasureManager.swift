//
//  MeasureManager.swift
//  gacha
//
//  Created by Oh Seojin on 10/23/25.
//

import Combine
import CoreMotion
import Foundation
import UIKit

protocol MeasureManager {
    var currentAngle: Double { get }
    var ExtensionAngle: Double { get }
    var FlexionAngle: Double { get }

    func startMeasuring()
    func stopMeasuring()
}
