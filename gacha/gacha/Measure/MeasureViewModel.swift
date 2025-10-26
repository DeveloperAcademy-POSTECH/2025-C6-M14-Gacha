//
//  MeasureViewModel.swift
//  gacha
//
//  Created by Oh Seojin on 10/26/25.
//

import Combine
import SwiftData
import SwiftUI

class MeasureViewModel: ObservableObject {
    private let repository: RecordRepository
    let measureManager: MotionMeasureManager

    @Published var currentRecord: MeasuredRecord? = nil
    @Published var allRecords: [MeasuredRecord] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    init(repository: RecordRepository) {
        self.repository = repository
        self.measureManager = MotionMeasureManager()
        self.measureManager.delegate = self
    }

    // MARK: - Extension 측정 완료 시
    func saveExtension(angle: Double) async {
        isLoading = true
        defer { isLoading = false }  // 현재 함수가 끝날 때 자동으로 실행

        do {
            let record = try await repository.createRecord(
                extensionAngle: angle
            )
            currentRecord = record
            print("✅ Extension 저장: \(angle)° (ID: \(record.id))")
        } catch {
            errorMessage = "Extension 저장 실패: \(error.localizedDescription)"
            print("❌ \(errorMessage ?? "")")
        }
    }

    // MARK: - Flexion 측정 완료 시
    func saveFlexion(angle: Double) async {
        guard let currentRecord = currentRecord else {
            errorMessage = "현재 레코드가 없습니다. Extension을 먼저 측정하세요."
            print("⚠️ \(errorMessage ?? "")")
            return
        }

        isLoading = true
        defer { isLoading = false }  // 현재 함수가 끝날 때 자동으로 실행

        let measurementMinutes = calculateMeasurementMinutes(
            from: currentRecord.measuredDate
        )
        do {
            let updated = try await repository.updateFlexion(
                recordId: currentRecord.id,
                flexionAngle: angle,
                measuredMinutes: measurementMinutes
            )
            self.currentRecord = updated

            print("✅ Flexion 저장: \(angle)°, \(measurementMinutes)분 소요")
            print("📊 ROM: \(updated.ROM ?? 0)°")
        } catch {
            errorMessage = "Flexion 저장 실패: \(error.localizedDescription)"
            print("❌ \(errorMessage ?? "")")
        }
    }

    // MARK: - PainLevel 측정 완료 시
    func savePainLevel(level: Int) async {
        guard let currentRecord = currentRecord else {
            errorMessage = "현재 레코드가 없습니다."
            print("⚠️ \(errorMessage ?? "")")
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let updated = try await repository.updatePainLevel(
                recordId: currentRecord.id,
                painLevel: level
            )
            self.currentRecord = updated

            print("✅ PainLevel 저장: \(level)")
        } catch {
            errorMessage = "PainLevel 저장 실패: \(error.localizedDescription)"
            print("❌ \(errorMessage ?? "")")
        }
    }

    // MARK: - 전체 레코드 조회
    func loadAllRecords() async {
        isLoading = true
        defer { isLoading = false }

        do {
            allRecords = try await repository.loadRecords()
            print("📚 레코드 로드 완료: \(allRecords.count)개")
        } catch {
            errorMessage = "레코드 로드 실패: \(error.localizedDescription)"
            print("❌ \(errorMessage ?? "")")
        }
    }

    // MARK: - 최근 레코드 조회
    func loadLatestRecord() async {
        isLoading = true
        defer { isLoading = false }

        do {
            currentRecord = try await repository.loadLatestRecord()

            if let record = currentRecord {
                print("📝 최근 레코드 로드: Extension \(record.extensionAngle)°")
            } else {
                print("⚠️ 저장된 레코드가 없습니다")
            }
        } catch {
            errorMessage = "최근 레코드 로드 실패: \(error.localizedDescription)"
            print("❌ \(errorMessage ?? "")")
        }
    }

    // MARK: - 새 측정 시작 (currentRecord 초기화)
    func startNewMeasurement() {
        currentRecord = nil
        errorMessage = nil
        print("🆕 새 측정 시작")
    }

    private func calculateMeasurementMinutes(from startDate: Date) -> Int {
        let elapsed = Date().timeIntervalSince(startDate)
        return Int(elapsed / 60)  // 초 → 분
    }
}

extension MeasureViewModel: MotionMeasureManagerDelegate {
      func motionManagerDidFinishRecording(type: KneeMotionType, angle: Double) {
          Task {
              switch type {
              case .extensionRom:
                  await saveExtension(angle: angle)
              case .flexionRom:
                  await saveFlexion(angle: angle)
              }
          }
      }
  }
