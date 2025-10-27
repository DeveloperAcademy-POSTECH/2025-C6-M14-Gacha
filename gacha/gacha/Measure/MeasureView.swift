//
//  MeasureView.swift
//  gacha
//
//  Created by Oh Seojin on 10/26/25.
//

import SwiftData
import SwiftUI

struct MeasureView: View {
    @EnvironmentObject var vm: MeasureViewModel
    @EnvironmentObject var measureManager: MotionMeasureManager

    var body: some View {
        VStack(spacing: 30) {
            Text("\(vm.measureManager.currentAngle)")
        }
        .onAppear {
            vm.measureManager.startMeasuring()  // 센서 시작
        }
        .onDisappear {
            vm.measureManager.stopMeasuring()  // 센서 중지
        }
    }
}

#Preview {
    MeasureView()
}
