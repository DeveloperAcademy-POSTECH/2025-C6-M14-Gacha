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
                let step: MeasureFlowStep = .extensionGuide
                navigationPath.append(step)
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
                    let step: MeasureFlowStep = .extensionMeasuring
                    navigationPath.append(step)
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
                    let step: MeasureFlowStep = .extensionChecked
                    navigationPath.append(step)
                }
            )
            .navigationBarHidden(true)
            
        case .extensionChecked:
            MeasureCheckedView(
                onComplete: {
                    let step: MeasureFlowStep = .flexionGuide
                    navigationPath.append(step)
                }
            )
            .navigationBarHidden(true)
            
        case .flexionGuide:
            FlexionMeasureView(
                session: session,
                onNext: {
                    let step: MeasureFlowStep = .flexionMeasuring
                    navigationPath.append(step)
                },
                onSkipToPain: {
                    session.flexionAngle = 0.0
                    let step: MeasureFlowStep = .painLevel
                    navigationPath.append(step)
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
                    let step: MeasureFlowStep = .flexionFinished
                    navigationPath.append(step)
                }
            )
            .navigationBarHidden(true)
            
        case .flexionFinished:
            MeasureFinishedView(
                onComplete: {
                    let step: MeasureFlowStep = .painLevel
                    navigationPath.append(step)
                }
            )
            .navigationBarHidden(true)
            
        case .painLevel:
            PainLevelView(
                session: session,
                onComplete: {
                    let step: MeasureFlowStep = .result
                    navigationPath.append(step)
                }
            )
            .navigationBarHidden(true)
            
        case .result:
            ProgressDetailView(
                session: session,
                onRemeasure: {
                    session.resetData()
                    navigationPath.removeLast(navigationPath.count)
                    let step: MeasureFlowStep = .extensionGuide
                    navigationPath.append(step)
                },
                onConfirm: {
                    let step: MeasureFlowStep = .summary
                    navigationPath.append(step)
                }
            )
            .navigationBarHidden(true)
            
        case .summary:
            DailyMeasureSummaryView(
                session: session,
                onRemeasure: {
                    session.resetData()
                    navigationPath.removeLast(navigationPath.count)
                    let step: MeasureFlowStep = .extensionGuide
                    navigationPath.append(step)
                },
                onDone: {
                    navigationPath.removeLast(navigationPath.count)
                }
            )
            .navigationBarHidden(true)
        }
    }
}
