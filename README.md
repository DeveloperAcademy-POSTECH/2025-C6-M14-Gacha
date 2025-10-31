# 무릎 재활 트래커

> 무릎 회복 과정을 기록하고 추적하는 iOS 앱

[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)]()
[![Xcode](https://img.shields.io/badge/Xcode-15.0-blue.svg)]()
[![iOS](https://img.shields.io/badge/iOS-17.0+-blue.svg)]()

---

## 소개

무릎 수술이나 부상 후 재활할 때 가장 중요한 게 꾸준한 기록입니다. 
이 앱은 iPhone 모션 센서로 무릎 가동 범위를 측정하고, 회복 추이를 시각화해서 보여줍니다.


## 프로젝트 기간
- 개발 기간: `2025.10.20 - 2025.10.31`


## 기술 스택

- **언어**: Swift
- **UI**: SwiftUI
- **데이터**: SwiftData
- **센서**: CoreMotion
- **차트**: Swift Charts
- **아키텍처**: MVVM


## 주요 기능

### 측정
- 무릎 펴짐 각도(신전) 측정
- 무릎 굽힘 각도(굴곡) 측정
- 가동 범위(ROM) 자동 계산

### 기록
- 주별 데이터 그래프
- 무릎 가동범위 변화 추이
- 통증 수준 기록 (VAS 0-10)

### 분석
- 이전 기록과 비교
- 상태별 피드백 메시지
- 악화 시 주의 안내


## 화면 구성 및 시연

| 기능 | 설명 |
|------|------|
| 측정 시작 | 측정 안내 및 자세 가이드 |
| 신전 측정 | 다리 펴진 상태 각도 측정 |
| 굴곡 측정 | 다리 굽힌 상태 각도 측정 |
| 통증 기록 | VAS 기반 통증 수준 입력 |
| 결과 확인 | 측정값 및 변화 분석 |
| 히스토리 | 주간 추이 그래프 |


## 폴더 구조

```
gacha/
┣ Models/
┃ ┣ MeasuredRecord.swift
┃ ┣ MotionMeasureManager.swift
┃ ┣ PatientStates.swift
┃ ┗ RecordRepository.swift
┣ ViewModels/
┃ ┣ MeasureViewModel.swift
┃ ┗ ProgressHistoryViewModel.swift
┣ Views/
┃ ┣ Measure/
┃ ┃ ┣ ExtensionMeasureView.swift
┃ ┃ ┣ FlexionMeasureView.swift
┃ ┃ ┗ PainLevelView.swift
┃ ┣ Progress/
┃ ┃ ┣ ProgressDetailView.swift
┃ ┃ ┗ ProgressHistoryView.swift
┃ ┗ Component/
┃   ┣ ButtonComponent.swift
┃   ┗ CapsuleButtonComponent.swift
┗ DesignSystem/
  ┣ Typography.swift
  ┗ ViewExtension.swift
```


## 팀 소개

| 이름 | 역할 | GitHub |
|------|------|--------|
| 차원준 | iOS Developer | [@chawj](https://github.com/chawj) |
| 오서진 | iOS Developer | [@seojin](https://github.com/seojin) |

## 브랜치 전략

- `main`: 안정 버전
- `dev`: 개발 통합 브랜치
- `feature/*`: 기능 개발
- `fix/*`: 버그 수정

## 커밋 컨벤션

Conventional Commits 사용

```
feat: 굴곡 측정 화면 구현
fix: 측정 데이터 저장 오류 수정
refactor: ViewModel 로직 분리
design: 버튼 컴포넌트 스타일 수정
docs: README 업데이트
```


## 실행 방법

### 요구사항
- Xcode 15.0+
- iOS 17.0+ 실제 기기 (시뮬레이터는 모션 센서 미지원)

### 설치
```bash
git clone https://github.com/yourteam/gacha.git
cd gacha
open gacha.xcodeproj
```

### 빌드
1. Xcode에서 프로젝트 열기
2. Signing & Capabilities에서 팀 설정
3. 실제 기기 연결
4. `Cmd + R` 실행


## 사용 방법

1. 평평한 곳에 앉아서 다리 펴기
2. iPhone을 허벅지 위에 올리기
3. 측정 버튼 길게 누르기 (3초)
4. 다리 구부린 상태로 한 번 더 측정
5. 통증 수준 입력
6. 결과 확인


## 주의사항

- 의료 기기가 아니며 전문 의료인 진단을 대체할 수 없습니다
- 측정 결과는 참고용으로만 활용하세요
- 정확한 진단은 의료 전문가와 상담이 필요합니다


## 개인정보 보호

모든 데이터는 기기 내부에만 저장되며 외부 서버로 전송되지 않습니다.


## License

Copyright © 2025. All rights reserved.
