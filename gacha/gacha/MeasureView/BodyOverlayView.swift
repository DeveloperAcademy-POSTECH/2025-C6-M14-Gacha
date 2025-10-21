//
//  File.swift
//  gacha
//
//  Created by Oh Seojin on 10/20/25.
//

import SwiftUI
import Vision

// MARK: - 신체 오버레이 뷰
/// 감지된 신체 위에 랜드마크와 연결선을 그리는 뷰
struct BodyOverlayView: View {
    let detectedBody: DetectedBody?

    var body: some View {
        GeometryReader { geometry in
            if let body = detectedBody {
                Canvas { context, size in
                    // 1. 관절 포인트 그리기
                    for (jointName, point) in body.points {
                        let location = convertVisionPoint(point.location, to: size)

                        // 관절을 원으로 표시
                        let circle = Path { path in
                            path.addEllipse(in: CGRect(x: location.x - 5, y: location.y - 5, width: 10, height: 10))
                        }
                        context.fill(circle, with: .color(.green))

                        // 관절 이름 표시 (선택사항)
                        // context.draw(Text(jointName.rawValue.description), at: location)
                    }

                    // 2. 연결선 그리기
                    drawBodyConnections(context: context, body: body, size: size)
                }
            }
        }
    }

    /// Vision 좌표를 화면 좌표로 변환하는 함수
    /// Vision은 좌표계가 (0,0)이 왼쪽 하단, (1,1)이 오른쪽 상단
    private func convertVisionPoint(_ point: CGPoint, to size: CGSize) -> CGPoint {
        return CGPoint(
            x: point.x * size.width,
            y: (1 - point.y) * size.height // Y축 반전
        )
    }

    /// 신체 연결선 그리기
    private func drawBodyConnections(context: GraphicsContext, body: DetectedBody, size: CGSize) {
        let connections: [(VNHumanBodyPoseObservation.JointName, VNHumanBodyPoseObservation.JointName)] = [
            // 오른쪽 팔
            (.rightShoulder, .rightElbow),
            (.rightElbow, .rightWrist),

            // 왼쪽 팔
            (.leftShoulder, .leftElbow),
            (.leftElbow, .leftWrist),

            // 오른쪽 다리
            (.rightHip, .rightKnee),
            (.rightKnee, .rightAnkle),

            // 왼쪽 다리
            (.leftHip, .leftKnee),
            (.leftKnee, .leftAnkle),

            // 몸통
            (.neck, .rightShoulder),
            (.neck, .leftShoulder),
            (.rightShoulder, .rightHip),
            (.leftShoulder, .leftHip),
            (.rightHip, .leftHip)
        ]

        for (start, end) in connections {
            if let startPoint = body.points[start],
               let endPoint = body.points[end] {

                let start = convertVisionPoint(startPoint.location, to: size)
                let end = convertVisionPoint(endPoint.location, to: size)

                var path = Path()
                path.move(to: start)
                path.addLine(to: end)

                context.stroke(path, with: .color(.blue), lineWidth: 2)
            }
        }
    }
}
