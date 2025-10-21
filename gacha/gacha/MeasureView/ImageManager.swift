//
//  ImageManager.swift
//  gacha
//
//  Created by Oh Seojin on 10/21/25.
//

import Foundation
import SwiftUI

func saveImage(_ flexionImage: UIImage, _ extensionImage: UIImage) -> (
    URL, URL
)? {
    // 1. Documents 디렉토리 경로 가져오기
    guard
        let documentsDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first
    else {
        print("❌ Documents 디렉토리를 찾을 수 없음")
        return nil
    }

    // 2. 고유한 파일명 생성 (관절이름 + MeasureRecord.timestamp)
    let timestamp = Int(Date().timeIntervalSince1970)

    let flextionFileName = "ROM_Knee_flexion_\(timestamp).jpg"
    let extensionFileName = "ROM_Knee_extension_\(timestamp).jpg"

    let flextionFileURL = documentsDirectory.appendingPathComponent(
        flextionFileName
    )
    let extensionFileURL = documentsDirectory.appendingPathComponent(
        extensionFileName
    )

    // 3. UIImage를 JPEG 데이터로 변환 (압축률 0.8)
    guard let flexionImageData = flexionImage.jpegData(compressionQuality: 0.8),
        let extensionImageData = extensionImage.jpegData(
            compressionQuality: 0.8
        )
    else {
        print("❌ 이미지를 JPEG로 변환 실패")
        return nil
    }

    // 4. 파일로 저장
    do {
        try flexionImageData.write(to: flextionFileURL)
        print("✅ 이미지 저장 성공: \(flextionFileURL)")

        try extensionImageData.write(to: extensionFileURL)
        print("✅ 이미지 저장 성공: \(extensionFileURL)")

        return (flextionFileURL, extensionFileURL)  // 파일명만 반환 (전체 경로 아님)
    } catch {
        print("❌ 이미지 저장 실패: \(error.localizedDescription)")
        return nil
    }
}

/// 파일명 또는 전체 경로로 이미지 로드
func loadImage(fileName: String) -> UIImage? {
    // 1. 전체 URL 경로인지 확인
    if fileName.hasPrefix("file://") || fileName.hasPrefix("/") {
        // 전체 경로에서 파일명만 추출
        let extractedFileName = URL(fileURLWithPath: fileName).lastPathComponent
        print("🔍 전체 경로에서 파일명 추출: \(extractedFileName)")
        return loadImageByFileName(extractedFileName)
    } else {
        // 파일명만 있는 경우
        return loadImageByFileName(fileName)
    }
}

/// 파일명으로 이미지 로드 (내부 함수)
private func loadImageByFileName(_ fileName: String) -> UIImage? {
    guard
        let documentsDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first
    else {
        print("❌ Documents 디렉토리를 찾을 수 없음")
        return nil
    }

    let fileURL = documentsDirectory.appendingPathComponent(fileName)

    // 파일 존재 여부 확인
    if !FileManager.default.fileExists(atPath: fileURL.path) {
        print("⚠️ 이미지 파일이 존재하지 않음: \(fileName)")
        print("   경로: \(fileURL.path)")
        return nil
    }

    guard let imageData = try? Data(contentsOf: fileURL) else {
        print("❌ 이미지 데이터 로드 실패: \(fileName)")
        return nil
    }

    let image = UIImage(data: imageData)
    if image != nil {
        print("✅ 이미지 로드 성공: \(fileName)")
    }
    return image
}
