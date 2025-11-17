//
//  Typography.swift
//  gacha
//
//  디자인 토큰 - 타이포그래피
//

import SwiftUI



// MARK: - Font Extension
extension Font {
/**Before (하드코딩)
  Text("통증수준 기록")
      .font(.system(size: 34, weight: .bold))
      .foregroundStyle(Color.black)

  After (디자인 토큰)

  Text("통증수준 기록")
      .font(.painTitle)  // 또는 .displayLarge
      .foregroundStyle(Color.black)
 **/
    
    // MARK: - Display
    // Large (34pt)
    static let displayLargeBold = Font.system(size: 34, weight: .bold)
    static let displayLargeSemibold = Font.system(size: 34, weight: .semibold)
    static let displayLargeMedium = Font.system(size: 34, weight: .medium)
    static let displayLargeRegular = Font.system(size: 34, weight: .regular)

    // Title1 (28pt)
    static let displayTitle1Bold = Font.system(size: 28, weight: .bold)
    static let displayTitle1Semibold = Font.system(size: 28, weight: .semibold)
    static let displayTitle1Medium = Font.system(size: 28, weight: .medium)
    static let displayTitle1Regular = Font.system(size: 28, weight: .regular)

    // Title2 (22pt)
    static let displayTitle2Bold = Font.system(size: 24, weight: .bold)
    static let displayTitle2Semibold = Font.system(size: 24, weight: .semibold)
    static let displayTitle2Medium = Font.system(size: 24, weight: .medium)
    static let displayTitle2Regular = Font.system(size: 24, weight: .regular)

    // Title3 (20pt)
    static let displayTitle3Bold = Font.system(size: 20, weight: .bold)
    static let displayTitle3Semibold = Font.system(size: 20, weight: .semibold)
    static let displayTitle3Medium = Font.system(size: 20, weight: .medium)
    static let displayTitle3Regular = Font.system(size: 20, weight: .regular)

    // Headline (17pt)
    static let displayHeadlineSemibold = Font.system(size: 17, weight: .semibold)

    // Body (17pt)
    static let displayBodyBold = Font.system(size: 17, weight: .bold)
    static let displayBodySemibold = Font.system(size: 17, weight: .semibold)
    static let displayBodyMedium = Font.system(size: 17, weight: .medium)
    static let displayBodyRegular = Font.system(size: 17, weight: .regular)

    // Callout (16pt)
    static let displayCalloutBold = Font.system(size: 16, weight: .bold)
    static let displayCalloutSemibold = Font.system(size: 16, weight: .semibold)
    static let displayCalloutMedium = Font.system(size: 16, weight: .medium)
    static let displayCalloutRegular = Font.system(size: 16, weight: .regular)
    
    // Subline (15pt)
    static let displaySublineBold = Font.system(size: 15, weight: .bold)
    static let displaySublineSemibold = Font.system(size: 15, weight: .semibold)
    static let displaySublineMedium = Font.system(size: 15, weight: .medium)
    static let displaySublineRegular = Font.system(size: 15, weight: .regular)


    // Footnote (13pt)
    static let displayFootnoteBold = Font.system(size: 13, weight: .bold)
    static let displayFootnoteSemibold = Font.system(size: 13, weight: .semibold)
    static let displayFootnoteMedium = Font.system(size: 13, weight: .medium)
    static let displayFootnoteRegular = Font.system(size: 13, weight: .regular)

    // Caption1 (12pt)
    static let displayCaption1Bold = Font.system(size: 12, weight: .bold)
    static let displayCaption1Semibold = Font.system(size: 12, weight: .semibold)
    static let displayCaption1Medium = Font.system(size: 12, weight: .medium)
    static let displayCaption1Regular = Font.system(size: 12, weight: .regular)

    // Caption2 (11pt)
    static let displayCaption2Bold = Font.system(size: 11, weight: .bold)
    static let displayCaption2Semibold = Font.system(size: 11, weight: .semibold)
    static let displayCaption2Medium = Font.system(size: 11, weight: .medium)
    static let displayCaption2Regular = Font.system(size: 11, weight: .regular)


    // MARK: - Rounded
    // ExtraLarge (60pt)
    static let roundedExtraLargeBold = Font.system(size: 60, weight: .bold, design: .rounded)
    
    // Large (34pt)
    static let roundedLargeBold = Font.system(size: 34, weight: .bold, design: .rounded)
    static let roundedLargeSemibold = Font.system(size: 34, weight: .semibold, design: .rounded)
    static let roundedLargeMedium = Font.system(size: 34, weight: .medium, design: .rounded)
    static let roundedLargeRegular = Font.system(size: 34, weight: .regular, design: .rounded)

    // Title1 (28pt)
    static let roundedTitle1Bold = Font.system(size: 28, weight: .bold, design: .rounded)
    static let roundedTitle1Semibold = Font.system(size: 28, weight: .semibold, design: .rounded)
    static let roundedTitle1Medium = Font.system(size: 28, weight: .medium, design: .rounded)
    static let roundedTitle1Regular = Font.system(size: 28, weight: .regular, design: .rounded)

    // Title2 (22pt)
    static let roundedTitle2Bold = Font.system(size: 24, weight: .bold, design: .rounded)
    static let roundedTitle2Semibold = Font.system(size: 24, weight: .semibold, design: .rounded)
    static let roundedTitle2Medium = Font.system(size: 24, weight: .medium, design: .rounded)
    static let roundedTitle2Regular = Font.system(size: 24, weight: .regular, design: .rounded)

    // Title3 (20pt)
    static let roundedTitle3Bold = Font.system(size: 20, weight: .bold, design: .rounded)
    static let roundedTitle3Semibold = Font.system(size: 20, weight: .semibold, design: .rounded)
    static let roundedTitle3Medium = Font.system(size: 20, weight: .medium, design: .rounded)
    static let roundedTitle3Regular = Font.system(size: 20, weight: .regular, design: .rounded)

    // Headline (17pt)
    static let roundedHeadlineSemibold = Font.system(size: 17, weight: .semibold, design: .rounded)

    // Body (17pt)
    static let roundedBodyBold = Font.system(size: 17, weight: .bold, design: .rounded)
    static let roundedBodySemibold = Font.system(size: 17, weight: .semibold, design: .rounded)
    static let roundedBodyMedium = Font.system(size: 17, weight: .medium, design: .rounded)
    static let roundedBodyRegular = Font.system(size: 17, weight: .regular, design: .rounded)

    // Callout (16pt)
    static let roundedCalloutBold = Font.system(size: 16, weight: .bold, design: .rounded)
    static let roundedCalloutSemibold = Font.system(size: 16, weight: .semibold, design: .rounded)
    static let roundedCalloutMedium = Font.system(size: 16, weight: .medium, design: .rounded)
    static let roundedCalloutRegular = Font.system(size: 16, weight: .regular, design: .rounded)

    // Footnote (13pt)
    static let roundedFootnoteBold = Font.system(size: 13, weight: .bold, design: .rounded)
    static let roundedFootnoteSemibold = Font.system(size: 13, weight: .semibold, design: .rounded)
    static let roundedFootnoteMedium = Font.system(size: 13, weight: .medium, design: .rounded)
    static let roundedFootnoteRegular = Font.system(size: 13, weight: .regular, design: .rounded)

    // Caption1 (12pt)
    static let roundedCaption1Bold = Font.system(size: 12, weight: .bold, design: .rounded)
    static let roundedCaption1Semibold = Font.system(size: 12, weight: .semibold, design: .rounded)
    static let roundedCaption1Medium = Font.system(size: 12, weight: .medium, design: .rounded)
    static let roundedCaption1Regular = Font.system(size: 12, weight: .regular, design: .rounded)

    // Caption2 (11pt)
    static let roundedCaption2Bold = Font.system(size: 11, weight: .bold, design: .rounded)
    static let roundedCaption2Semibold = Font.system(size: 11, weight: .semibold, design: .rounded)
    static let roundedCaption2Medium = Font.system(size: 11, weight: .medium, design: .rounded)
    static let roundedCaption2Regular = Font.system(size: 11, weight: .regular, design: .rounded)
}
