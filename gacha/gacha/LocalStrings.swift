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
        static var retake: String {
            NSLocalizedString("common.retake", comment: "")
        }
        static var backHome: String {
            NSLocalizedString("common.back_home", comment: "")
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
        static var instructionPage1: String {
            NSLocalizedString("daily_start.instruction_page1", comment: "")
        }
        static var instructionPage2: String {
            NSLocalizedString("daily_start.instruction_page2", comment: "")
        }
        static var buttonNext: String {
            NSLocalizedString("daily_start.button_next", comment: "")
        }
        static var buttonMeasure: String {
            NSLocalizedString("daily_start.button_measure", comment: "")
        }
        static var buttonPainOnly: String {
            NSLocalizedString("daily_start.button_pain_only", comment: "")
        }
    }
    
    // MARK: - FlexionMeasure
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
        enum QuitMeasure {
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
    
    // MARK: - PainLevel
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
        
        enum PainNormal {
            static var title: String {
                NSLocalizedString("progress.pain_normal.title", comment: "")
            }
            static var description: String {
                NSLocalizedString("progress.pain_normal.description", comment: "")
            }
        }
        
        enum PainCaution {
            static var title: String {
                NSLocalizedString("progress.pain_caution.title", comment: "")
            }
            static var description: String {
                NSLocalizedString("progress.pain_caution.description", comment: "")
            }
            static var emphasis: String {
                NSLocalizedString("progress.pain_caution.emphasis", comment: "")
            }
        }
        
        enum PainWarning {
            static var title: String {
                NSLocalizedString("progress.pain_warning.title", comment: "")
            }
            static var description: String {
                NSLocalizedString("progress.pain_warning.description", comment: "")
            }
            static var emphasis: String {
                NSLocalizedString("progress.pain_warning.emphasis", comment: "")
            }
        }
        
        enum FirstTake {
            static var title: String {
                NSLocalizedString("progress.first_take.title", comment: "")
            }
            static var description: String {
                NSLocalizedString("progress.first_take.description", comment: "")
            }
        }
    }
    
    // MARK: - Card
    enum Card {
        static var flexionAngle: String {
            NSLocalizedString("card.flexion_angle", comment: "")
        }
        static var kneeROM: String {
            NSLocalizedString("card.knee_ROM", comment: "")
        }
        static var painLevel: String {
            NSLocalizedString("card.pain_level", comment: "")
        }
    }
    
    // MARK: - History
    enum History {
        static var title: String {
            NSLocalizedString("history.title", comment: "")
        }
        static var romTitle: String {
            NSLocalizedString("history.rom_title", comment: "")
        }
        static var average: String {
            NSLocalizedString("history.average", comment: "")
        }
        static var painTitle: String {
            NSLocalizedString("history.pain_title", comment: "")
        }
        static var painMin: String {
            NSLocalizedString("history.pain_min", comment: "")
        }
        static var painMax: String {
            NSLocalizedString("history.pain_max", comment: "")
        }
    }
    
    // MARK: - MainViewB
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
