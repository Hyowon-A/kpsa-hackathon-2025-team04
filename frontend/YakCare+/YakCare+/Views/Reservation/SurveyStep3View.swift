import SwiftUI

// MARK: - Survey Step 3 View
struct SurveyStep3View: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(NavigationRouter.self) private var router

    // 7~12번 답변을 인덱스로 관리
    @State private var answer7: Int? = nil
    @State private var answer8: Int? = nil
    @State private var answer9: Int? = nil
    @State private var answer10: Int? = nil
    @State private var answer11: Int? = nil
    @State private var answer12: Int? = nil

    // 공통 옵션
    private let options = ["매우 좋음", "좋음", "보통", "나쁨", "매우 나쁨"]

    var body: some View {
        VStack(spacing: 0) {
            // 상단: NavBar + Progress
            SurveyNavBarProgressView(current: 3, total: 3)
                .padding(.bottom, 30)

            ScrollView {
                VStack(alignment: .leading, spacing: 40) {
                    // — 생활습관(운동,수면,식사)관리
                    Text("생활습관(운동,수면,식사)관리")
                        .font(.system(size: 16, weight: .semibold))

                    // 7번~9번
                    surveyQuestionView(
                        number: 7,
                        text: "규칙적인 운동을 하고 있나요?",
                        selection: $answer7
                    )
                    surveyQuestionView(
                        number: 8,
                        text: "평소 충분한 수면을 취하시나요?",
                        selection: $answer8
                    )
                    surveyQuestionView(
                        number: 9,
                        text: "본인의 식습관은 건강하다고 생각하시나요?",
                        selection: $answer9
                    )

                    // — 정신·감정 상태
                    Text("정신·감정 상태")
                        .font(.system(size: 16, weight: .semibold))

                    // 10번~12번
                    surveyQuestionView(
                        number: 10,
                        text: "평소 마음이 안정적이라고 느끼시나요?",
                        selection: $answer10
                    )
                    surveyQuestionView(
                        number: 11,
                        text: "스트레스로 인한 신체적 증상을 거의 경험하지 않는 편인가요?",
                        selection: $answer11
                    )
                    surveyQuestionView(
                        number: 12,
                        text: "스트레스로 인한 신체적 증상을 거의 경험하지 않는 편인가요?",
                        selection: $answer12
                    )
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }

            // 하단 고정 버튼
            HStack(spacing: 8) {
                Button(action: { router.pop() }) {
                    Text("이전")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(12)
                }
                Button(action: {
                    // TODO: 다음 액션
                    router.push(.surveyStep4)
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

    // 질문용 재사용 뷰
    @ViewBuilder
    private func surveyQuestionView(
        number: Int,
        text: String,
        selection: Binding<Int?>
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\(number). \(text)")
                .font(.system(size: 14))
            HStack(spacing: 10) {
                ForEach(Array(options.enumerated()), id: \.offset) { idx, label in
                    RadioButton(
                        label: label,
                        isSelected: selection.wrappedValue == idx
                    ) {
                        selection.wrappedValue = idx
                    }
                }
            }
        }
    }
}

// MARK: - Preview
struct SurveyStep3View_Previews: PreviewProvider {
    static var previews: some View {
        SurveyStep3View()
            .environment(NavigationRouter())
    }
}
