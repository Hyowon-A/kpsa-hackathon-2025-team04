import SwiftUI

// MARK: - Radio Button
struct RadioButton: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                // 동그라미
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        .frame(width: 16, height: 16)
                    if isSelected {
                        Circle()
                            .fill(Color.gray.opacity(0.5))
                            .frame(width: 8, height: 8)
                    }
                }
                Text(label)
                    .font(.system(size: 14))
                    .foregroundColor(.primary)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Survey Step 2 View
struct SurveyStep2View: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(NavigationRouter.self) private var router
    // 1~6번 답변을 인덱스로 관리
    @State private var answer1: Int? = nil
    @State private var answer2: Int? = nil
    @State private var answer3: Int? = nil
    @State private var answer4: Int? = nil
    @State private var answer5: Int? = nil
    @State private var answer6: Int? = nil

    // 공통 옵션
    private let options = ["매우 좋음", "좋음", "보통", "나쁨", "매우 나쁨"]

    var body: some View {
        VStack(spacing: 0) {
            // 상단: NavBar + Progress
            SurveyNavBarProgressView(current: 2, total: 3)
                .padding(.bottom, 30)

            ScrollView {
                VStack(alignment: .leading, spacing: 40) {
                    // — 전반적 건강 인식
                    Text("전반적 건강 인식")
                        .font(.system(size: 16, weight: .semibold))

                    // 1번
                    VStack(alignment: .leading, spacing: 12) {
                        Text("1. 본인의 건강 상태를 전반적으로 어떻게 평가하시나요?")
                            .font(.system(size: 14))
                        HStack(spacing: 10) {
                            ForEach(Array(options.enumerated()), id: \.offset) { idx, label in
                                RadioButton(
                                    label: label,
                                    isSelected: answer1 == idx
                                ) { answer1 = idx }
                            }
                        }
                    }

                    // 2번
                    VStack(alignment: .leading, spacing: 12) {
                        Text("2. 최근 1년간 건강 상태는 어떤 편이라고 생각하시나요?")
                            .font(.system(size: 14))
                        HStack(spacing: 10) {
                            ForEach(Array(options.enumerated()), id: \.offset) { idx, label in
                                RadioButton(
                                    label: label,
                                    isSelected: answer2 == idx
                                ) { answer2 = idx }
                            }
                        }
                    }

                    // 3번
                    VStack(alignment: .leading, spacing: 12) {
                        Text("3. 건강 상태가 점점 좋아지는다고 느끼나요?")
                            .font(.system(size: 14))
                        HStack(spacing: 10) {
                            ForEach(Array(options.enumerated()), id: \.offset) { idx, label in
                                RadioButton(
                                    label: label,
                                    isSelected: answer3 == idx
                                ) { answer3 = idx }
                            }
                        }
                    }

                    // — 일상기능 & 체력
                    Text("일상기능 & 체력")
                        .font(.system(size: 16, weight: .semibold))

                    // 4번
                    VStack(alignment: .leading, spacing: 12) {
                        Text("4. 일상생활을 하면서 쉽게 피로를 느끼지 않는 편이신가요?")
                            .font(.system(size: 14))
                        HStack(spacing: 10) {
                            ForEach(Array(options.enumerated()), id: \.offset) { idx, label in
                                RadioButton(
                                    label: label,
                                    isSelected: answer4 == idx
                                ) { answer4 = idx }
                            }
                        }
                    }

                    // 5번
                    VStack(alignment: .leading, spacing: 12) {
                        Text("5. 건강 문제로 인해 하고 싶은 일을 포기한 적이 없나요?")
                            .font(.system(size: 14))
                        HStack(spacing: 10) {
                            ForEach(Array(options.enumerated()), id: \.offset) { idx, label in
                                RadioButton(
                                    label: label,
                                    isSelected: answer5 == idx
                                ) { answer5 = idx }
                            }
                        }
                    }

                    // 6번
                    VStack(alignment: .leading, spacing: 12) {
                        Text("6. 평소 에너지가 넘치고 활력이 있다고 느끼시나요?")
                            .font(.system(size: 14))
                        HStack(spacing: 10) {
                            ForEach(Array(options.enumerated()), id: \.offset) { idx, label in
                                RadioButton(
                                    label: label,
                                    isSelected: answer6 == idx
                                ) { answer6 = idx }
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }

            // 하단 고정 버튼
            HStack(spacing: 8) {
                Button(action: {
                    // 이전 페이지로
                    router.pop()
                }) {
                    Text("이전")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(12)
                }
                Button(action: {
                    // 다음 액션
                    router.push(.surveyStep3)
                }) {
                    Text("다음")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal, 16)

        }
        .padding(.horizontal, 16)
        .navigationBarBackButtonHidden()
    }
}

// MARK: - Preview
struct SurveyStep2View_Previews: PreviewProvider {
    static var previews: some View {
        SurveyStep2View()
            .environment(NavigationRouter())
    }
}
