import SwiftUI

// MARK: - Progress Indicator
struct SurveyProgressView: View {
    let current: Int
    let total: Int

    var body: some View {
        VStack(spacing: 4) {
            Text("\(current) / \(total)")
                .font(.system(size: 14))
            ProgressView(value: Double(current), total: Double(total))
                .accentColor(Color.gray.opacity(0.3))
                .frame(height: 4)
                .cornerRadius(2)
        }
        .frame(width: 77)
    }
}

struct Checkbox: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .foregroundColor(.green)
                Text(label)
                    .foregroundColor(.primary)
                    .font(.system(size: 14))
            }
        }
        .buttonStyle(.plain)
    }
}

struct SurveyCheckboxQuestion: View {
    let question: String
    @Binding var selections: Set<String>
    let options: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(question)
                .font(.system(size: 14))

            VStack(alignment: .leading, spacing: 12) {
                ForEach(options, id: \.self) { option in
                    Checkbox(label: option, isSelected: selections.contains(option)) {
                        if selections.contains(option) {
                            selections.remove(option)
                        } else {
                            selections.insert(option)
                        }
                    }
                }
            }
        }
    }
}


// MARK: - Dropdown Question
struct SurveyDropdownQuestion: View {
    let question: String
    @Binding var selection: String
    let options: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(question)
                .font(.system(size: 14))
            Menu {
                ForEach(options, id: \.self) { option in
                    Button(option) { selection = option }
                }
            } label: {
                HStack {
                    Text(selection)
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 16, weight: .medium))
                }
                .padding()
                .background(Color.gray.opacity(0.3))
                .cornerRadius(12)
            }
        }
    }
}

// MARK: - NavBar + Progress Component
struct SurveyNavBarProgressView: View {
    @Environment(\.dismiss) private var dismiss
    let current: Int
    let total: Int

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.black)
                    }
                    Spacer()
                }
                HStack {
                    Spacer()
                    VStack(spacing: 4) {
                        Text("설문조사")
                            .font(.system(size: 22, weight: .semibold))
                        Text("객관적 지표")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
            }
            Spacer().frame(height: 10)
            SurveyProgressView(current: current, total: total)
        }
    }
}

// MARK: - Survey View
struct SurveyView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(NavigationRouter.self) private var router
    
    @State private var answer1: Set<String> = []
    @State private var answer2: Set<String> = []
    @State private var answer3: Set<String> = []
    @State private var answer4: Set<String> = []

    private let options1 = [
        "고혈압 약",
        "당뇨병 약",
        "고지혈증 약",
        "통풍 약",
        "위장약",
        "수면제",
        "항우울제, 항불안제",
        "진통제",
        "감기약 / 호흡기 관련 약",
        "피부질환 약",
        "피임약 / 생리통약",
        "다이어트 약",
        "항생제",
        "항암제"
    ]

    private let options2 = [
        "종합비타민",
        "비타민B군",
        "비타민C",
        "비타민D (칼슘)",
        "오메가3 (혈행 개선)",
        "유산균 (장 건강)",
        "루테인 / 지아잔틴 (눈 건강)",
        "밀크씨슬 (간 건강)",
        "마그네슘",
        "콜라겐 (피부 건강)",
        "프로폴리스 (면역력)",
        "철분 (여성 건강)",
        "한약"
    ]

    private let options3 = [
        "고혈압",
        "당뇨병",
        "고지혈증",
        "심장질환",
        "뇌혈관질환",
        "신장질환",
        "간질환",
        "폐질환",
        "통풍",
        "골다공증 / 골절",
        "위염 / 위궤양",
        "암 진단 이력",
        "정신건강 질환 (치매, 우울증 등)",
        "여성질환 (다낭성난소증후군, 자궁근종 등)",
        "기타 질환 / 수술 이력",
        "과거에 병원에서 진단받은 적 없음"
    ]

    private let options4 = [
        "고혈압",
        "당뇨병",
        "고지혈증",
        "심장질환",
        "뇌혈관질환",
        "신장질환",
        "간질환",
        "폐질환",
        "통풍",
        "골다공증 / 골절",
        "위염 / 위궤양",
        "암 진단 이력",
        "정신건강 질환 (치매, 우울증 등)",
        "여성질환 (다낭성난소증후군, 자궁근종 등)",
        "기타 질환 / 수술 이력",
        "과거에 병원에서 진단받은 적 없음"
    ]

    var body: some View {
        VStack(spacing: 0) {
            SurveyNavBarProgressView(current: 1, total: 3)
                .padding(.bottom, 30)
                .padding(.horizontal, 12)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 40) {
                    SurveyCheckboxQuestion(
                        question: "1. 현재 복용하고 있는 약물이 있나요?",
                        selections: $answer1,
                        options: options1
                    )
                    SurveyCheckboxQuestion(
                        question: "2. 최근 2주간 꾸준히 복용 중인 영양제가 있나요?",
                        selections: $answer2,
                        options: options2
                    )
                    SurveyCheckboxQuestion(
                        question: "3. 과거에 진단받은 질환이나 치료받은 병력이 있다면 모두 선택해주세요. (현재 앓고 있는 질환 포함)",
                        selections: $answer3,
                        options: options3
                    )
                    SurveyCheckboxQuestion(
                        question: "4. 가족 중에 아래 질환을 진단 받으신 분이 있다면 모두 선택해주세요.",
                        selections: $answer4,
                        options: options4
                    )
                }

                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 16)
            }
            PrimaryButton(title: "다음") {
                // 다음 액션
                router.push(.surveyStep2)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .navigationBarBackButtonHidden()
    }
}

// MARK: - Preview
struct SurveyView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SurveyView()
                .environment(NavigationRouter())
        }
    }
}
