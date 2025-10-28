//
//  MeasureFlowView.swift
//  gacha
//
//  Created by 차원준 on 10/28/25.
//


import SwiftUI

struct MeasureFlowView: View {
    @Environment(\.modelContext) private var modelContext
    
    // 측정 세션 (데이터만 관리)
    @State private var session = MeasureSession()
    
    // 네비게이션 경로 (화면 이동 관리)
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            // 루트 화면: DailyMeasureStartView
            homeView()
                .navigationDestination(for: MeasureFlowStep.self) { step in
                    viewForStep(step)
                }
        }
    }
    
    // MARK: - View Builders
    
    @ViewBuilder
    private func homeView() -> some View {
        DailyMeasureStartView(
            session: session,
            onStartMeasure: {
                navigationPath.append(MeasureFlowStep.extensionGuide)
            }
        )
    }
    
    @ViewBuilder
    private func viewForStep(_ step: MeasureFlowStep) -> some View {
        switch step {
        case .home:
            homeView()
            
        case .extensionGuide:
            ExtensionMeasureView(
                session: session,
                onNext: {
                    navigationPath.append(.extensionMeasuring)
                },
                onBack: {
                    navigationPath.removeLast()
                }
            )
            .navigationBarBackButtonHidden(true)
            
        case .extensionMeasuring:
            ContentView(
                session: session,
                motionType: .extensionRom,
                onComplete: {
                    navigationPath.append(.flexionGuide)
                }
            )
            .navigationBarHidden(true)
            
        case .flexionGuide:
            FlexionMeasureView(
                session: session,
                onNext: {
                    navigationPath.append(.flexionMeasuring)
                },
                onSkipToPain: {
                    session.flexionAngle = 0.0
                    navigationPath.append(.painLevel)
                },
                onCancel: {
                    session.resetData()
                    navigationPath.removeLast(navigationPath.count)
                }
            )
            .navigationBarBackButtonHidden(true)
            
        case .flexionMeasuring:
            ContentView(
                session: session,
                motionType: .flexionRom,
                onComplete: {
                    navigationPath.append(.painLevel)
                }
            )
            .navigationBarHidden(true)
            
        case .painLevel:
            PainLevelView(
                session: session,
                onComplete: {
                    navigationPath.append(.result)
                }
            )
            .navigationBarHidden(true)
            
        case .result:
            ProgressDetailView(
                session: session,
                onRemeasure: {
                    session.resetData()
                    navigationPath.removeLast(navigationPath.count)
                    navigationPath.append(.extensionGuide)
                },
                onConfirm: {
                    navigationPath.append(.summary)
                }
            )
            .navigationBarHidden(true)
            
        case .summary:
            DailyMeasureSummaryView(
                session: session,
                onRemeasure: {
                    session.resetData()
                    navigationPath.removeLast(navigationPath.count)
                    navigationPath.append(.extensionGuide)
                },
                onDone: {
                    navigationPath.removeLast(navigationPath.count)
                }
            )
            .navigationBarHidden(true)
        }
    }
}
