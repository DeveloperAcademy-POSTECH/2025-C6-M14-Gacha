//
//  LocalStrings.swift
//  gacha
//
//  Created by 차원준 on 10/29/25.
//

/*
//MARK: 사용방법

// 기존
Text("오늘의 측정")
    .font(.system(size: 34, weight: .bold))
Text("다시 측정할 경우 기존 기록은 정리됩니다.")
    .font(.system(size: 15, weight: .medium))

// 변경 후
Text(Strings.Summary.title)
    .font(.system(size: 34, weight: .bold))
Text(Strings.Summary.description)
    .font(.system(size: 15, weight: .medium))
*/

import Foundation

enum Strings {
    // MARK: - Common
    enum Common {
        static var confirm: String {
            NSLocalizedString("common.confirm", comment: "")
        }
        static var yes: String {
            NSLocalizedString("common.yes", comment: "")
        }
        static var no: String {
            NSLocalizedString("common.no", comment: "")
        }
        static var continueText: String {
            NSLocalizedString("common.continue", comment: "")
        }
        static var backToStart: String {
            NSLocalizedString("common.back_to_start", comment: "")
        }
        static var skip: String {
            NSLocalizedString("common.skip", comment: "")
        }
    }
    
    // MARK: - DailyMeasureStartView
    enum DailyStart {
        static var title: String {
            NSLocalizedString("daily_start.title", comment: "")
        }
        static var description: String {
            NSLocalizedString("daily_start.description", comment: "")
        }
        static var instruction: String {
            NSLocalizedString("daily_start.instruction", comment: "")
        }
        static var button: String {
            NSLocalizedString("daily_start.button", comment: "")
        }
    }
    
    // MARK: - ExtensionMeasureView
    enum Extension {
        static var instruction: String {
            NSLocalizedString("extension.instruction", comment: "")
        }
        static var instructionEmphasis: String {
            NSLocalizedString("extension.instruction_emphasis", comment: "")
        }
        static var measuring: String {
            NSLocalizedString("extension.measuring", comment: "")
        }
    }
    
    // MARK: - FlexionMeasureView
    enum Flexion {
        static var instruction: String {
            NSLocalizedString("flexion.instruction", comment: "")
        }
        static var instructionEmphasis: String {
            NSLocalizedString("flexion.instruction_emphasis", comment: "")
        }
        static var measuring: String {
            NSLocalizedString("flexion.measuring", comment: "")
        }
        static var skipButton: String {
            NSLocalizedString("flexion.skip_button", comment: "")
        }
    }
    
    // MARK: - Alerts
    enum Alert {
        enum QuitExtension {
            static var title: String {
                NSLocalizedString("alert.quit_extension.title", comment: "")
            }
            static var message: String {
                NSLocalizedString("alert.quit_extension.message", comment: "")
            }
        }
        
        enum SkipFlexion {
            static var title: String {
                NSLocalizedString("alert.skip_flexion.title", comment: "")
            }
            static var message: String {
                NSLocalizedString("alert.skip_flexion.message", comment: "")
            }
        }
        
        enum Remeasure {
            static var title: String {
                NSLocalizedString("alert.remeasure.title", comment: "")
            }
            static var message: String {
                NSLocalizedString("alert.remeasure.message", comment: "")
            }
        }
    }
    
    // MARK: - MeasureDoneView
    enum MeasureDone {
        static var title: String {
            NSLocalizedString("measure_done.title", comment: "")
        }
        static var subtitle: String {
            NSLocalizedString("measure_done.subtitle", comment: "")
        }
    }
    
    // MARK: - PainLevelView
    enum Pain {
        static var title: String {
            NSLocalizedString("pain.title", comment: "")
        }
        static var description: String {
            NSLocalizedString("pain.description", comment: "")
        }
        static var button: String {
            NSLocalizedString("pain.button", comment: "")
        }
        
        /// 통증 레벨 0-10
        static func level(_ value: Int) -> String {
            NSLocalizedString("pain.level.\(value)", comment: "")
        }
    }
    
    // MARK: - ProgressDetailView
    enum Progress {
        static var title: String {
            NSLocalizedString("progress.title", comment: "")
        }
        
        enum Excellent {
            static var title: String {
                NSLocalizedString("progress.excellent.title", comment: "")
            }
            static var description: String {
                NSLocalizedString("progress.excellent.description", comment: "")
            }
        }
        
        enum Good {
            static var title: String {
                NSLocalizedString("progress.good.title", comment: "")
            }
            static var description: String {
                NSLocalizedString("progress.good.description", comment: "")
            }
        }
        
        enum Same {
            static var title: String {
                NSLocalizedString("progress.same.title", comment: "")
            }
            static var description: String {
                NSLocalizedString("progress.same.description", comment: "")
            }
        }
        
        enum Normal {
            static var title: String {
                NSLocalizedString("progress.normal.title", comment: "")
            }
            static var description: String {
                NSLocalizedString("progress.normal.description", comment: "")
            }
        }
        
        enum Caution {
            static var title: String {
                NSLocalizedString("progress.caution.title", comment: "")
            }
            static var description: String {
                NSLocalizedString("progress.caution.description", comment: "")
            }
            static var emphasis: String {
                NSLocalizedString("progress.caution.emphasis", comment: "")
            }
        }
        
        enum Warning {
            static var title: String {
                NSLocalizedString("progress.warning.title", comment: "")
            }
            static var description: String {
                NSLocalizedString("progress.warning.description", comment: "")
            }
            static var emphasis: String {
                NSLocalizedString("progress.warning.emphasis", comment: "")
            }
        }
    }
    
    // MARK: - ProgressHistoryView
    enum History {
        static var title: String {
            NSLocalizedString("history.title", comment: "")
        }
        static var romTitle: String {
            NSLocalizedString("history.rom_title", comment: "")
        }
        static var painTitle: String {
            NSLocalizedString("history.pain_title", comment: "")
        }
    }
    
    // MARK: - DailyMeasureSummaryView
    enum Summary {
        static var title: String {
            NSLocalizedString("summary.title", comment: "")
        }
        static var description: String {
            NSLocalizedString("summary.description", comment: "")
        }
        static var button: String {
            NSLocalizedString("summary.button", comment: "")
        }
    }
}
