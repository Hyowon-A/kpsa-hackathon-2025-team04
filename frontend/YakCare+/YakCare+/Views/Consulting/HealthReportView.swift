import SwiftUI

struct HealthReportView: View {
    @Environment(NavigationRouter.self) private var router
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var surveyVM: SurveyViewModel
    @EnvironmentObject var contentsVM: ContentsViewModel

    @State private var selectedTab = 0
    @State private var username: String = "사용자"
    @State private var totalScore: Int = 0

    private let tabs = ["객관적 건강 수치 평가", "주관적 건강 평가"]
    private let warningItems = ["ALT(간기능)", "eGFR(신장기능)"]

    var body: some View {
        VStack(spacing: 0) {
            NavBarView {
                router.push(.home)
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HeaderView(username: username)

                    SegmentedTabsView(tabs: tabs, selectedIndex: $selectedTab)

                    Spacer().frame(height: 50)

                    if selectedTab == 0 {
                        GaugeView(score: totalScore)
                            .frame(width: 200, height: 100)
                            .padding(.horizontal, 24)
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        Text("주관적 건강 점수: \(surveyVM.totalScore)점")
                            .font(.title3)
                            .fontWeight(.bold)
                            .padding(.vertical, 20)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }

                    LegendView()

                    Text("건강검진 결과 분석")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 24)

                    AnalysisSectionView(titles: ["주의", "위험"], items: [warningItems, warningItems])

                    if let response = $contentsVM.surveyResponse {
                        SummarySectionView(
                            medications: response.total_score.medications,
                            supplements: response.total_score.supplements,
                            pastConditions: response.total_score.past_conditions,
                            familyHistory: response.total_score.family_history
                        )

                        RecommendationsSectionView(
                            supplements: response.supplement_list.supplements,
                            username: response.username
                        )
                    }

                    .padding(.horizontal, 24)


                    RecommendationsSectionView(count: 3, username: username)
                }
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarBackButtonHidden()
        .onAppear {
            loadMockSurveyResponse()
        }
    }

    private func loadMockSurveyResponse() {
        self.username = "이효주"
        self.totalScore = 84
    }
}


// MARK: - NavBarView
struct NavBarView: View {
    var backAction: () -> Void
    var body: some View {
        HStack {
            Button(action: backAction) {
                Image(systemName: "house.fill")
                    .foregroundColor(.black)
            }
            Spacer()
        }
        .padding()
    }
}

// MARK: - HeaderView
struct HeaderView: View {
    var username: String
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(Color.gray.opacity(0.4))
                .frame(width: 60, height: 60)
            VStack(alignment: .leading, spacing: 4) {
                Text("\(username)님의 건강분석 레포트")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text("2003. 08. 05생 / 여 / 정밀검사")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding()
        .frame(width: UIScreen.main.bounds.width * 0.9, alignment: .leading)
        .background(Color.gray.opacity(0.2))
        .clipShape(RoundedCorner(radius: 16, corners: [.topRight, .bottomRight]))
    }
}

// MARK: - SegmentedTabsView
struct SegmentedTabsView: View {
    let tabs: [String]
    @Binding var selectedIndex: Int

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { idx in
                Text(tabs[idx])
                    .font(.caption)
                    .foregroundColor(selectedIndex == idx ? .black : .gray)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        ZStack {
                            if selectedIndex == idx {
                                Capsule()
                                    .fill(Color.white)
                                    .padding(3)
                                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 2, y: 2)
                            }
                        }
                    )
                    .onTapGesture {
                        withAnimation(.easeInOut) { selectedIndex = idx }
                    }
            }
        }
        .frame(height: 36)
        .background(
            Capsule()
                .fill(Color.gray.opacity(0.2))
                .shadow(color: Color.black.opacity(0.15), radius: 4, x: 4, y: 4)
        )
        .padding(.horizontal, 24)
    }
}

// MARK: - LegendView
struct LegendView: View {
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top, spacing: 8) {
                Circle()
                    .fill(Color.gray.opacity(0.4))
                    .frame(width: 7, height: 7)
                Text("객관적 건강 수치 평가 요소")
                    .font(.caption2)
            }
            Text("연령 / 키, 몸무게(BMI) / 현재 질병 상태 및 활력 증대 여부 / 국가건강검진 수치")
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - AnalysisSectionView
struct AnalysisSectionView: View {
    let titles: [String]
    let items: [[String]]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 16) {
                ForEach(0..<titles.count, id: \.self) { idx in
                    AnalysisColumn(title: titles[idx], items: items[idx])
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        .padding(.horizontal, 24)
    }
}

// MARK: - SummarySectionView
struct SummarySectionView: View {
    let medications: [String]
    let supplements: [String]
    let pastConditions: [String]
    let familyHistory: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("검진 내용 요약")
                .font(.subheadline)
                .fontWeight(.semibold)

            SummaryItemView(title: "복용 약물", items: medications)
            SummaryItemView(title: "복용 영양제 또는 건기식", items: supplements)
            SummaryItemView(title: "과거력", items: pastConditions)
            SummaryItemView(title: "가족력", items: familyHistory)
        }
    }
}

struct SummaryItemView: View {
    let title: String
    let items: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            if items.isEmpty {
                Text("- 없음")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            } else {
                ForEach(items, id: \.self) { item in
                    Text("- \(item)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            Divider()
        }
    }
}

// MARK: - RecommendationsSectionView
struct RecommendationsSectionView: View {
    let count: Int
    let username: String

    var body: some View {
        VStack(spacing: 0) {
            Text("\(username)님께 딱 맞는 건강기능식품 추천")
                .font(.subheadline)
                .fontWeight(.semibold)
                .padding(.bottom, 8)

            HStack(spacing: 12) {
                ForEach(0..<count, id: \.self) { _ in
                    RecommendationCard()
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(Color.gray.opacity(0.1))
        }
    }
}

// MARK: - 기존 Subcomponents (변경 없음)

struct GaugeView: View {
    let score: Int
    private let diameter: CGFloat = 200

    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0.0, to: 0.5)
                .rotation(.degrees(180))
                .stroke(style: StrokeStyle(
                    lineWidth: 14,
                    lineCap: .round
                ))
                .foregroundColor(Color.gray.opacity(0.3))
                .frame(width: diameter, height: diameter)
            Circle()
                .trim(from: 0.0, to: CGFloat(score) / 1000 * 0.5)
                .rotation(.degrees(180))
                .stroke(style: StrokeStyle(
                    lineWidth: 14,
                    lineCap: .round
                ))
                .foregroundColor(Color.blue)
                .frame(width: diameter, height: diameter)
            VStack(spacing: 4) {
                Text("파워 긍정형 개복치")
                    .font(.system(size: 12, weight: .bold))
                Text("\(score)점")
                    .font(.system(size: 24, weight: .bold))
            }
        }
    }
}

struct AnalysisColumn: View {
    let title: String
    let items: [String]
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
            ForEach(items, id: \.self) { item in
                Text("[\(item)]")
                    .font(.caption2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct RecommendationCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 100, height: 100)
            Group {
                Text("추천사유:")
                    .font(.caption2)
                    .fontWeight(.semibold)
                Text("주요효과:")
                    .font(.caption2)
                    .fontWeight(.semibold)
                Text("DDI 및 주의사항:")
                    .font(.caption2)
                    .fontWeight(.semibold)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

fileprivate struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner
    func path(in rect: CGRect) -> Path {
        Path(UIBezierPath(roundedRect: rect, byRoundingCorners: corners,
                          cornerRadii: CGSize(width: radius, height: radius)).cgPath)
    }
}

// MARK: - Preview
struct HealthReportView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HealthReportView()
                .environment(NavigationRouter())
        }
    }
}
