//
//  LocalStrings.swift
//  gacha
//
//  Created by 김순주 on 11/14/25.
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
        static var yes: String { NSLocalizedString("common.yes", comment: "") }
        static var no: String { NSLocalizedString("common.no", comment: "") }
        static var cancel: String { NSLocalizedString("common.cancel", comment: "") }
        static var confirm: String { NSLocalizedString("common.confirm", comment: "") }
    }
    
    // MARK: - Button
    enum Button {
        static var next: String { NSLocalizedString("button.next", comment: "") }
        static var measure: String { NSLocalizedString("button.measure", comment: "") }
        static var measureStart: String { NSLocalizedString("button.measure.start", comment: "") }
        static var retake: String { NSLocalizedString("button.retake", comment: "") }
        static var painOnly: String { NSLocalizedString("button.pain_only", comment: "") }
        static var save: String { NSLocalizedString("button.save", comment: "") }
        static var cancel: String { NSLocalizedString("button.cancel", comment: "") }
        static var back: String { NSLocalizedString("button.back", comment: "") }
        static var close: String { NSLocalizedString("button.close", comment: "") }
        static var home: String { NSLocalizedString("button.home", comment: "") }
    }
    
    // MARK: - Tabbar
    enum Tabbar {
        static var calendar: String { NSLocalizedString("tabbar.calendar", comment: "") }
        static var measure: String { NSLocalizedString("tabbar.measure", comment: "") }
        static var summary: String { NSLocalizedString("tabbar.summary", comment: "") }
    }
    
    // MARK: - Alerts
    enum Alert {
        static var cancelFlexionTitle: String { NSLocalizedString("alert.cancel.flexion.title", comment: "") }
        static var cancelFlexionMessage: String { NSLocalizedString("alert.cancel.flexion.message", comment: "") }
        static var cancelPainTitle: String { NSLocalizedString("alert.cancel.pain.title", comment: "") }
        static var cancelPainMessage: String { NSLocalizedString("alert.cancel.pain.message", comment: "") }
        static var remeasureTitle: String { NSLocalizedString("alert.remeasure.title", comment: "") }
        static var remeasureMessage: String { NSLocalizedString("alert.remeasure.message", comment: "") }
        static var notyetTitle: String { NSLocalizedString("alert.notyet.title", comment: "")
        }
        static var notyetMessage: String { NSLocalizedString("alert.notyet.message", comment: "")
        }
        static var rerecordPainTitle: String { NSLocalizedString("alert.rerecord_pain.title", comment: "")
        }
        static var rerecordPainMessage: String { NSLocalizedString("alert.rerecord_pain.message", comment: "")
        }
    }
    
    // MARK: - MainBefore
    enum DailyStart {
        static var title: String { NSLocalizedString("daily_start.title", comment: "") }
        static var instructionNo1: String { NSLocalizedString("daily_start.instruction.no1", comment: "") }
        static var instructionNo2: String { NSLocalizedString("daily_start.instruction.no2", comment: "") }
        static var instructionNo3: String { NSLocalizedString("daily_start.instruction.no3", comment: "") }
    }
    
    // MARK: - CountdownView
    enum Countdown {
        static var emphasisText: String { NSLocalizedString("measure.countdown.emphasis_text", comment: "") }
        static var description: String { NSLocalizedString("measure.countdown.description", comment: "")
        }
    }
    
    // MARK: - FlexionMeasureView
    enum Flexion {
        static var title: String { NSLocalizedString("measure.flexion.title", comment: "") }
        static var flexionMeasuring: String { NSLocalizedString("measure.flexion.measuring", comment: "") }
        static var flexionMeasured: String { NSLocalizedString("measure.flexion.measured", comment: "") }
    }
    
    // MARK: - Pain Level View
    enum Pain {
        static var title: String { NSLocalizedString("pain.title", comment: "") }
        static var description: String { NSLocalizedString("pain.description", comment: "") }
    }
    
    // MARK: - Pain Categories
    enum PainCategory {
        static var none: String { NSLocalizedString("pain.category.0", comment: "") }
        static var mild: String { NSLocalizedString("pain.category.1to3", comment: "") }
        static var moderate: String { NSLocalizedString("pain.category.4to6", comment: "") }
        static var severe: String { NSLocalizedString("pain.category.7to9", comment: "") }
        static var extreme: String { NSLocalizedString("pain.category.10", comment: "") }

        static func category(for value: Int) -> String {
            switch value {
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
        static var title: String { NSLocalizedString("progress.title", comment: "") }
        static var flexionAngle: String { NSLocalizedString("progress.flexion_angle", comment: "") }
        static var painLevel: String { NSLocalizedString("progress.pain_level", comment: "") }
        
        static var firstRecordTitle: String { NSLocalizedString("progress.first_record.title", comment: "") }
        static var firstRecordDescription: String { NSLocalizedString("progress.first_record.description", comment: "") }
        
        static var betterNoPainTitle: String { NSLocalizedString("progress.better_nopain.title", comment: "") }
        static var betterNoPainDescription: String { NSLocalizedString("progress.better_nopain.description", comment: "") }

        static var betterMildPainTitle: String { NSLocalizedString("progress.better_mildpain.title", comment: "") }
        static var betterMildPainDescription: String { NSLocalizedString("progress.better_mildpain.description", comment: "") }
        
        static var betterModeratePainTitle: String { NSLocalizedString("progress.better_moderatepain.title", comment: "") }
        static var betterModeratePainDescription: String { NSLocalizedString("progress.better_moderatepain.description", comment: "") }
        
        static var betterSeverePainTitle: String { NSLocalizedString("progress.better_severepain.title", comment: "") }
        static var betterSeverePainDescription: String { NSLocalizedString("progress.better_severepain.description", comment: "") }
        
        static var betterExcruciatingPainTitle: String { NSLocalizedString("progress.better_excruciatingpain.title", comment: "") }
        static var betterExcruciatingPainDescription: String { NSLocalizedString("progress.better_excruciatingpain.description", comment: "") }
        
        static var sameNoPainTitle: String { NSLocalizedString("progress.same_nopain.title", comment: "") }
        static var sameNoPainDescription: String { NSLocalizedString("progress.same_nopain.description", comment: "") }
        
        static var sameMildPainTitle: String { NSLocalizedString("progress.same_mildpain.title", comment: "") }
        static var sameMildPainDescription: String { NSLocalizedString("progress.same_mildpain.description", comment: "") }
        
        static var sameModeratePainTitle: String { NSLocalizedString("progress.same_moderatepain.title", comment: "") }
        static var sameModeratePainDescription: String { NSLocalizedString("progress.same_moderatepain.description", comment: "") }
        
        static var sameSeverePainTitle: String { NSLocalizedString("progress.same_severepain.title", comment: "") }
        static var sameSeverePainDescription: String { NSLocalizedString("progress.same_severepain.description", comment: "") }
        
        static var sameExcruciatingPainTitle: String { NSLocalizedString("progress.same_excruciatingpain.title", comment: "") }
        static var sameExcruciatingPainDescription: String { NSLocalizedString("progress.same_excruciatingpain.description", comment: "") }
        
        static var worseNoPainTitle: String { NSLocalizedString("progress.worse_nopain.title", comment: "") }
        static var worseNoPainDescription: String { NSLocalizedString("progress.worse_nopain.description", comment: "") }
        
        static var worseMildPainTitle: String { NSLocalizedString("progress.worse_mildpain.title", comment: "") }
        static var worseMildPainDescription: String { NSLocalizedString("progress.worse_mildpain.description", comment: "") }
        
        static var worseModeratePainTitle: String { NSLocalizedString("progress.worse_moderatepain.title", comment: "") }
        static var worseModeratePainDescription: String { NSLocalizedString("progress.worse_moderatepain.description", comment: "") }
        
        static var worseSeverePainTitle: String { NSLocalizedString("progress.worse_severepain.title", comment: "") }
        static var worseSeverePainDescription: String { NSLocalizedString("progress.worse_severepain.description", comment: "") }
        
        static var worseExcruciatingPainTitle: String { NSLocalizedString("progress.worse_excruciatingpain.title", comment: "") }
        static var worseExcruciatingPainDescription: String { NSLocalizedString("progress.worse_excruciatingpain.description", comment: "") }
    }
    
    // MARK: - History
    enum History {
        static var summaryTitle: String { NSLocalizedString("history.summary.title", comment: "") }

        // Card - ROM
        static var cardRomTitle: String { NSLocalizedString("history.card.rom.title", comment: "") }
        static func cardRomBetter(days: Int, degrees: Int) -> String {
            String(format: NSLocalizedString("history.card.rom.better", comment: ""), days, degrees)
        }
        static func cardRomSame(days: Int) -> String {
            String(format: NSLocalizedString("history.card.rom.same", comment: ""), days)
        }
        static func cardRomWorse(days: Int, degrees: Int) -> String {
            String(format: NSLocalizedString("history.card.rom.worse", comment: ""), days, degrees)
        }
        static func cardRomUnder2Days(days: Int) -> String {
            String(format: NSLocalizedString("history.card.rom.under2Days", comment: ""), days)
        }
        static var cardRomUnder2: String { NSLocalizedString("history.card.rom.under2", comment: "") }

        // Card - Pain
        static var cardPainTitle: String { NSLocalizedString("history.card.pain.title", comment: "") }
        static var cardPainStep: String { NSLocalizedString("history.card.pain.step", comment: "")}
        static func cardPainBetter(levels: Int) -> String {
            String(format: NSLocalizedString("history.card.pain.better", comment: ""), levels)
        }
        static var cardPainSame: String { NSLocalizedString("history.card.pain.same", comment: "") }
        static func cardPainWorse(levels: Int) -> String {
            String(format: NSLocalizedString("history.card.pain.worse", comment: ""), levels)
        }
        static var cardPainNoRecord: String { NSLocalizedString("history.card.pain.no_record", comment: "") }
        static var cardPainFirstRecord: String { NSLocalizedString("history.card.pain.first_record", comment: "") }

        // Chart - ROM
        static var chartRomTitle: String { NSLocalizedString("history.chart.rom.title", comment: "") }
        static func chartRomBetter(prevMax: Int, improvement: Int) -> String {
            String(format: NSLocalizedString("history.chart.rom.better", comment: ""), prevMax, improvement)
        }
        static func chartRomSame(prevMax: Int) -> String {
            String(format: NSLocalizedString("history.chart.rom.same", comment: ""), prevMax)
        }
        static func chartRomWorse(prevMax: Int, decline: Int) -> String {
            String(format: NSLocalizedString("history.chart.rom.worse", comment: ""), prevMax, decline)
        }
        static var chartRomNoRecord: String { NSLocalizedString("history.chart.rom.no_record", comment: "") }
        static func chartRomFirstRecord(angle: Int) -> String {
            String(format: NSLocalizedString("history.chart.rom.first_record", comment: ""), angle)
        }

        // Chart - Pain
        static var chartPainTitle: String { NSLocalizedString("history.chart.pain.title", comment: "") }
        static func chartPainBetter(improvement: Int, from: Int) -> String {
            String(format: NSLocalizedString("history.chart.pain.better", comment: ""), improvement, from)
        }
        static func chartPainSame(level: Int) -> String {
            String(format: NSLocalizedString("history.chart.pain.same", comment: ""), level)
        }
        static func chartPainWorse(increase: Int, from: Int) -> String {
            String(format: NSLocalizedString("history.chart.pain.worse", comment: ""), from, increase)
        }
        static var chartPainNoRecord: String { NSLocalizedString("history.chart.pain.no_record", comment: "") }
        static func chartPainFirstRecord(level: Int) -> String {
            String(format: NSLocalizedString("history.chart.pain.first_record", comment: ""), level)
        }
    }
    
    // MARK: - Select Type
    enum SelectType {
        static var title: String { NSLocalizedString("select.type.title", comment: "") }
        
        enum Knee {
            enum Flexion {
                static var title: String { NSLocalizedString("select.type.knee.flexion.title", comment: "") }
                static var description: String { NSLocalizedString("select.type.knee.flexion.description", comment: "") }
            }
        }
        
        enum Shoulder {
            enum Flexion {
                static var title: String { NSLocalizedString("select.type.shoulder.flexion.title", comment: "") }
                static var description: String { NSLocalizedString("select.type.shoulder.flexion.description", comment: "") }
            }
        }
        
        enum Hip {
            enum Adduction {
                static var title: String { NSLocalizedString("select.type.hip.adduction.title", comment: "") }
                static var description: String { NSLocalizedString("select.type.hip.adduction.description", comment: "") }
            }
        }
        
        enum Elbow {
            enum Extension {
                static var title: String { NSLocalizedString("select.type.elbow.extension.title", comment: "") }
                static var description: String { NSLocalizedString("select.type.elbow.extension.description", comment: "") }
            }
        }
    }
}
