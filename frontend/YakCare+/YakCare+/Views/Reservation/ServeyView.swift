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

// MARK: - Text Question
struct SurveyTextQuestion: View {
    let question: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(question)
                .font(.system(size: 14))
            TextField("직접입력", text: $text)
                .padding()
                .background(Color.gray.opacity(0.3))
                .cornerRadius(12)
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
                    Button(option) {
                        selection = option
                    }
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

// MARK: - Survey View
struct SurveyView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var answer1 = ""
    @State private var answer2 = "종합비타민"
    @State private var answer3 = "고혈압"
    @State private var answer4 = "암(위)"
    private let options2 = ["종합비타민", "비타민 D", "유산균", "루테인"]
    private let options3 = ["고혈압", "당뇨병"]
    private let options4 = ["암(위)", "심장질환", "고혈압", "당뇨병"]

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack {
                    // Custom Navigation Bar
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
                    
                    // Progress Indicator
                    SurveyProgressView(current: 1, total: 3)
                    
                    Spacer().frame(height: 30)
                    
                    VStack(spacing: 40) {
                        // Questions
                        SurveyTextQuestion(
                            question: "1. 현재 복용하고 있는 약물이 있나요?",
                            text: $answer1
                        )
                        SurveyDropdownQuestion(
                            question: "2. 최근 2주간 꾸준히 복용 중인 영양제가 있나요?",
                            selection: $answer2,
                            options: options2
                        )
                        SurveyDropdownQuestion(
                            question: "3. 과거에 진단받은 질환이나 치료받은 병력이 있다면 모두 선택해주세요. (현재 앓고 있는 질환 포함)",
                            selection: $answer3,
                            options: options3
                        )
                        SurveyDropdownQuestion(
                            question: "4. 가족 중에 아래 질환을 진단 받으신 분이 있다면 모두 선택해주세요.",
                            selection: $answer4,
                            options: options4
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 16)
            }
            // Fixed Next Button at bottom
            PrimaryButton(title: "다음") {
                // 다음 액션
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
    }
}

// MARK: - Preview
struct SurveyView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SurveyView()
        }
    }
}
