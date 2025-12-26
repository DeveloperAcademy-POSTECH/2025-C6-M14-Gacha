# Anggle

> **하루 1분,  
> 앙글과 함께 더 나은 내일을 만들어보세요**  
>
> 어디서나 간편한 무릎 재활 기록 —  
> **3초면 충분한 나만의 재활 체크**

![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![Xcode](https://img.shields.io/badge/Xcode-15.0-blue)
![iOS](https://img.shields.io/badge/iOS-17.0+-blue)

---

## ✨ 소개

**Anggle** 은 iPhone의 모션 센서를 활용해  
무릎 관절 가동 범위(ROM)와 통증 정도를 **빠르고 직관적으로 기록**할 수 있는  
무릎 재활 기록 앱입니다.

감각에 의존하던 재활 과정을  
**숫자와 그래프로 확인 가능한 데이터**로 제공합니다.

## 👥 팀원

| 이름 | 역할 |
|----|----|
| 전유진 | Product Manager |
| 오서진 | iOS Developer |
| 차원준 | iOS Developer |
| 김순주 | UX Writer |
| 임준혁 | UI/UX Designer |
| 황지민 | UI/UX Designer |

---

## ❓ 기획 배경

무릎 재활은 회복 속도를 체감하기 어렵습니다.

꾸준히 운동해도  
> *“내가 정말 좋아지고 있는 걸까?”*  

라는 불안은 쉽게 사라지지 않습니다.

Anggle은 **아이폰을 허벅지에 올리고 무릎을 굽히는 것만으로**  
즉시 각도를 측정하고 기록할 수 있도록 만들었습니다.

---

## 🎯 대상 사용자

- 무릎 수술(ACL 등) 후 회복 중인 사용자
- 무릎 부상으로 재활 치료를 진행 중인 사용자
- 무릎 관절 가동 범위(ROM)를 **수치로 관리**하고 싶은 사용자
- 재활 경과를 **객관적인 데이터**로 확인하고 싶은 사용자

---

## 🧩 주요 기능

### 📐 측정
- 무릎 관절 가동 범위(ROM)
- 굴곡(Flexion) / 신전(Extension)
- 통증 수준 기록 (VAS 0–10)

### 📊 기록
- 주간 ROM 변화 그래프
- 측정 기록 히스토리
- 통증 변화 추적

### 🔍 분석
- 이전 기록 대비 변화 비교
- 상태 기반 피드백 제공
- 악화 시 주의 안내

---

## ▶️ 사용 방법

1. 앉은 상태에서 측정할 다리 준비
2. iPhone을 허벅지 또는 정강이에 밀착
3. 측정 버튼을 누르고 자세 유지
4. 무릎을 굽혀 다시 측정
5. 통증 수준 입력 후 결과 확인

---

## 🛠 기술 스택

- **Language**: Swift  
- **UI**: SwiftUI  
- **Architecture**: MVVM  
- **Data**: SwiftData  
- **Sensor**: CoreMotion  
- **Chart**: Swift Charts  
- **Minimum iOS**: 17.0+

---

## 🗂 프로젝트 구조

```text
gacha/
├── Models/
├── ViewModels/
├── Views/
│   ├── Measure/
│   ├── Progress/
│   └── Component/
└── DesignSystem/
```

---

## 📄 License

Copyright © 2025 Anggle Team.  
All rights reserved.
