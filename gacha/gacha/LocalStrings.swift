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
        static var yes: String {
            NSLocalizedString("common.yes", comment: "")
        }
        static var no: String {
            NSLocalizedString("common.no", comment: "")
        }
        static var retake: String {
            NSLocalizedString("common.retake", comment: "")
        }
        static var cancel: String {
            NSLocalizedString("common.cancel", comment: "")
        }
        static var confirm: String {
            NSLocalizedString("common.confirm", comment: "")
        }
    }
    
    // MARK: - Button
    enum Button {
        static var next: String {
            NSLocalizedString("button.next", comment: "")
        }
        static var measure: String {
            NSLocalizedString("button.measure", comment: "")
        }
        static var save: String {
            NSLocalizedString("button.save", comment: "")
        }
    }
    
    // MARK: - Tabbar
    enum Tabbar {
        static var calendar: String {
            NSLocalizedString("tabbar.calendar", comment: "")
        }
        static var measure: String {
            NSLocalizedString("tabbar.measure", comment: "")
        }
        static var summary: String {
            NSLocalizedString("tabbar.summary", comment: "")
        }
    }
    
    // MARK: - Alerts
    enum Alert {
        static var cancelFlexionHeadline: String {
            NSLocalizedString("alert.cancel_flexion.headline", comment: "")
        }
        static var quitExtensionMessage: String {
            NSLocalizedString("alert.quit_extension.message", comment: "")
        }
        static var cancelPainHeadline: String {
            NSLocalizedString("alert.cancel_pain.headline", comment: "")
        }
        static var cancelPainMessage: String {
            NSLocalizedString("alert.cancel_pain.message", comment: "")
        }
        static var remeasureHeadline: String {
            NSLocalizedString("alert.remeasure.headline", comment: "")
        }
        static var remeasureMessage: String {
            NSLocalizedString("alert.remeasure.message", comment: "")
        }
        
        enum CancelPain {
            static var title: String {
                NSLocalizedString("alert.cancel_pain.headline", comment: "")
            }
            static var message: String {
                NSLocalizedString("alert.cancel_pain.message", comment: "")
            }
            static var messageFromHome: String {
                NSLocalizedString("alert.cancel_pain_from_home.message", comment: "")
            }
        }
    }
    
    // MARK: - Main (Before)
    enum DailyStart {
        static var titleLarge: String {
            NSLocalizedString("daily_start.title_large", comment: "")
        }
        static var instruction: String {
            NSLocalizedString("daily_start.instruction", comment: "")
        }
        static var instruction2: String {
            NSLocalizedString("daily_start.instruction2", comment: "")
        }
        static var enterPainOnly: String {
            NSLocalizedString("enter.pain_only", comment: "")
        }
    }
    
    // MARK: - MeasureView (Loading)
    enum Measure {
        static var title: String {
            NSLocalizedString("measure.title", comment: "")
        }
        static var loadingBold: String {
            NSLocalizedString("flexion.loading.instruction_bold24", comment: "")
        }
        static var loadingInstruction: String {
            NSLocalizedString("flexion.loading.instruction", comment: "")
        }
    }
    
    // MARK: - FlexionMeasureView
    enum Flexion {
        static var instruction: String {
            NSLocalizedString("flexion.instruction_semibold24", comment: "")
        }
        static var measuring: String {
            NSLocalizedString("flexion.measuring_semibold24", comment: "")
        }
        static var measured: String {
            NSLocalizedString("flexion.measured_semibold24", comment: "")
        }
    }
    
    // MARK: - Pain Level View
    enum Pain {
        static var title: String {
            NSLocalizedString("pain.title", comment: "")
        }
        static var description: String {
            NSLocalizedString("pain.description", comment: "")
        }
        static var romMeasure: String {
            NSLocalizedString("pain.rom_measure", comment: "")
        }
    }
    
    // MARK: - Pain Categories
    enum PainCategory {
        static var none: String {
            NSLocalizedString("pain.category.0", comment: "")
        }
        static var mild: String {
            NSLocalizedString("pain.category.1to3", comment: "")
        }
        static var moderate: String {
            NSLocalizedString("pain.category.4to6", comment: "")
        }
        static var severe: String {
            NSLocalizedString("pain.category.7to9", comment: "")
        }
        static var extreme: String {
            NSLocalizedString("pain.category.10", comment: "")
        }

        /// 통증 수준 값에 따른 카테고리 문자열 반환
        static func category(for level: Int) -> String {
            switch level {
            case 0:
                return none
            case 1...3:
                return mild
            case 4...6:
                return moderate
            case 7...9:
                return severe
            case 10:
                return extreme
            default:
                return none
            }
        }
    }
    
    // MARK: - Pain Levels
    enum PainLevel {
        static var level0: String { NSLocalizedString("pain.level.0", comment: "") }
        static var level1: String { NSLocalizedString("pain.level.1", comment: "") }
        static var level2: String { NSLocalizedString("pain.level.2", comment: "") }
        static var level3: String { NSLocalizedString("pain.level.3", comment: "") }
        static var level4: String { NSLocalizedString("pain.level.4", comment: "") }
        static var level5: String { NSLocalizedString("pain.level.5", comment: "") }
        static var level6: String { NSLocalizedString("pain.level.6", comment: "") }
        static var level7: String { NSLocalizedString("pain.level.7", comment: "") }
        static var level8: String { NSLocalizedString("pain.level.8", comment: "") }
        static var level9: String { NSLocalizedString("pain.level.9", comment: "") }
        static var level10: String { NSLocalizedString("pain.level.10", comment: "") }

        /// 통증 수준 값에 따른 설명 문자열 반환
        static func level(for value: Int) -> String {
            switch value {
            case 0: return level0
            case 1: return level1
            case 2: return level2
            case 3: return level3
            case 4: return level4
            case 5: return level5
            case 6: return level6
            case 7: return level7
            case 8: return level8
            case 9: return level9
            case 10: return level10
            default: return level0
            }
        }
    }
    
    // MARK: - Progress (After Measure)
    enum Progress {
        static var titleLarge: String {
            NSLocalizedString("progress.title_large", comment: "")
        }
        
        static var flexionAngle: String {
            NSLocalizedString("card.flexion_angle", comment: "")
        }
        static var painLevel: String {
            NSLocalizedString("card.pain_level", comment: "")
        }
        
        static var firstTakeHeadline: String {
            NSLocalizedString("progress.first_take.headline", comment: "")
        }
        static var firstTakeDescription: String {
            NSLocalizedString("progress.first_take.description", comment: "")
        }
        
        static var betterNoPainHeadline: String {
            NSLocalizedString("progress.better_nopain.headline", comment: "")
        }
        static var betterNoPainDescription: String {
            NSLocalizedString("progress.better_nopain.description", comment: "")
        }
        
        static var betterMildPainHeadline: String {
            NSLocalizedString("progress.better_mildpain.headline", comment: "")
        }
        static var betterMildPainDescription: String {
            NSLocalizedString("progress.better_mildpain.description", comment: "")
        }
        
        static var betterModeratePainHeadline: String {
            NSLocalizedString("progress.better_moderatepain.headline", comment: "")
        }
        static var betterModeratePainDescription: String {
            NSLocalizedString("progress.better_moderatepain.description", comment: "")
        }
        
        static var betterSeverePainHeadline: String {
            NSLocalizedString("progress.better_severepain.headline", comment: "")
        }
        static var betterSeverePainDescription: String {
            NSLocalizedString("progress.better_severepain.description", comment: "")
        }
        
        static var betterExcruciatingPainHeadline: String {
            NSLocalizedString("progress.better_excruciatingpain.headline", comment: "")
        }
        static var betterExcruciatingPainDescription: String {
            NSLocalizedString("progress.better_excruciatingpain.description", comment: "")
        }
        
        static var sameNoPainHeadline: String {
            NSLocalizedString("progress.same_nopain.headline", comment: "")
        }
        static var sameNoPainDescription: String {
            NSLocalizedString("progress.same_nopain.description", comment: "")
        }
        
        static var sameMildPainHeadline: String {
            NSLocalizedString("progress.same_mildpain.headline", comment: "")
        }
        static var sameMildPainDescription: String {
            NSLocalizedString("progress.same_mildpain.description", comment: "")
        }
        
        static var sameModeratePainHeadline: String {
            NSLocalizedString("progress.same_moderatepain.headline", comment: "")
        }
        static var sameModeratePainDescription: String {
            NSLocalizedString("progress.same_moderatepain.description", comment: "")
        }
        
        static var sameSeverePainHeadline: String {
            NSLocalizedString("progress.same_severepain.headline", comment: "")
        }
        static var sameSeverePainDescription: String {
            NSLocalizedString("progress.same_severepain.description", comment: "")
        }
        
        static var sameExcruciatingPainHeadline: String {
            NSLocalizedString("progress.same_excruciatingpain.headline", comment: "")
        }
        static var sameExcruciatingPainDescription: String {
            NSLocalizedString("progress.same_excruciatingpain.description", comment: "")
        }
        
        static var worseNoPainHeadline: String {
            NSLocalizedString("progress.worse_nopain.headline", comment: "")
        }
        static var worseNoPainDescription: String {
            NSLocalizedString("progress.worse_nopain.description", comment: "")
        }
        
        static var worseMildPainHeadline: String {
            NSLocalizedString("progress.worse_mildpain.headline", comment: "")
        }
        static var worseMildPainDescription: String {
            NSLocalizedString("progress.worse_mildpain.description", comment: "")
        }
        
        static var worseModeratePainHeadline: String {
            NSLocalizedString("progress.worse_moderatepain.headline", comment: "")
        }
        static var worseModeratePainDescription: String {
            NSLocalizedString("progress.worse_moderatepain.description", comment: "")
        }
        
        static var worseSeverePainHeadline: String {
            NSLocalizedString("progress.worse_severepain.headline", comment: "")
        }
        static var worseSeverePainDescription: String {
            NSLocalizedString("progress.worse_severepain.description", comment: "")
        }
        
        static var worseExcruciatingPainHeadline: String {
            NSLocalizedString("progress.worse_excruciatingpain.headline", comment: "")
        }
        static var worseExcruciatingPainDescription: String {
            NSLocalizedString("progress.worse_excruciatingpain.description", comment: "")
        }
    }
    
    // MARK: - HistoryView
    enum History {
        static var titleLarge: String {
            NSLocalizedString("history.title_large", comment: "")
        }
        static var romHeadline: String {
            NSLocalizedString("history.rom_headline", comment: "")
        }
        static var romSubBetter: String {
            NSLocalizedString("history.rom_subheadline_better", comment: "")
        }
        static var romSubSame: String {
            NSLocalizedString("history.rom_subheadline_same", comment: "")
        }
        static var romSubWorse: String {
            NSLocalizedString("history.rom_subheadline_worse", comment: "")
        }
        
        static var painHeadline: String {
            NSLocalizedString("history.pain_headline", comment: "")
        }
        static var painSubBetter: String {
            NSLocalizedString("history.pain_subheadline_better", comment: "")
        }
        static var painSubSame: String {
            NSLocalizedString("history.pain_subheadline_same", comment: "")
        }
        static var painSubWorse: String {
            NSLocalizedString("history.pain_subheadline_worse", comment: "")
        }
        static var painSubNoRecord: String {
            NSLocalizedString("history.pain_subheadline_norecord", comment: "")
        }
        static var painSubOneRecord: String {
            NSLocalizedString("history.pain_subheadline_1record", comment: "")
        }
        
        static var romTitle: String {
            NSLocalizedString("history.rom_title", comment: "")
        }
        static var romBetter: String {
            NSLocalizedString("history.rom_semibold15_better", comment: "")
        }
        static var romSame: String {
            NSLocalizedString("history.rom_semibold15_same", comment: "")
        }
        static var romWorse: String {
            NSLocalizedString("history.rom_semibold15_worse", comment: "")
        }
        static var romNoRecord: String {
            NSLocalizedString("history.semibold15_norecord", comment: "")
        }
        
        static var painTitle: String {
            NSLocalizedString("history.pain_title", comment: "")
        }
        static var painBetter: String {
            NSLocalizedString("history.pain_semibold15_better", comment: "")
        }
        static var painSame: String {
            NSLocalizedString("history.pain_semibold15_same", comment: "")
        }
        static var painWorse: String {
            NSLocalizedString("history.pain_semibold15_worse", comment: "")
        }
        static var painNoRecord: String {
            NSLocalizedString("history.pain_semibold15_norecord", comment: "")
        }
        
        // MARK: - History Summary Card Changes
        static func romChangeIncreased(days: Int, degrees: Int) -> String {
            String(format: NSLocalizedString("history.rom_change_increased", comment: ""), days, degrees)
        }
        
        static func romChangeDecreased(days: Int, degrees: Int) -> String {
            String(format: NSLocalizedString("history.rom_change_decreased", comment: ""), days, degrees)
        }
        
        static func painChangeDecreased(levels: Int) -> String {
            String(format: NSLocalizedString("history.pain_change_decreased", comment: ""), levels)
        }
        
        static func painChangeIncreased(levels: Int) -> String {
            String(format: NSLocalizedString("history.pain_change_increased", comment: ""), levels)
        }
    }
}
