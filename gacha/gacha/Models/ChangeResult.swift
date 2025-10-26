//
//  ChangeResult.swift
//  gacha
//
//  Created by 차원준 on 10/23/25.
//

struct ChangeResult {
    // 굴곡 각도의 차이와 상태
    let flexRomDiff: Double
    let flexRomDiffState: RomChangeState

    // 신전 각도의 차이와 상태
    let extenRomDiff: Double
    let extenRomDiffState: RomChangeState

    // 통증의 변화와 상태
    let painDiff: Double
    let painDiffState: PainChangeState
}
