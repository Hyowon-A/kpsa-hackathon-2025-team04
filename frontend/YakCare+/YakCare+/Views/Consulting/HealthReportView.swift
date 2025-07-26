import SwiftUI

struct HealthReportView: View {
    @Environment(\.presentationMode) private var presentationMode
    @State private var selectedTab = 0
    private let tabs = ["객관적 건강 수치 평가", "주관적 건강 평가"]
    private let score = 714
    private let warningItems = ["ALT(간기능)", "eGFR(신장기능)"]
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - NavBar
            HStack {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                }
                Spacer()
            }
            .padding()
            
            ScrollView {
                VStack(spacing: 16) {
                    
                    // MARK: - Header
                    HStack(spacing: 16) {
                        Circle()
                            .fill(Color.gray.opacity(0.4))
                            .frame(width: 60, height: 60)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("000님의 건강분석 레포트")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text("2006. 08. 14생 / 여 / 정밀검사")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                    .padding()
                    .frame(width: UIScreen.main.bounds.width * 0.9, alignment: .leading)
                    .background(Color.gray.opacity(0.2))
                    .clipShape(RoundedCorner(radius: 16, corners: [.topRight, .bottomRight]))
                    
                    // MARK: - Segmented Tabs
                    HStack(spacing: 0) {
                        ForEach(0..<tabs.count, id: \.self) { idx in
                            Text(tabs[idx])
                                .font(.caption)
                                .foregroundColor(selectedTab == idx ? .black : .gray)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(
                                    ZStack {
                                        if selectedTab == idx {
                                            Capsule()
                                                .fill(Color.white)
                                                .padding(3) // 내부 여백
                                                // 선택된 캡슐 그림자 (아래오른쪽 / 위왼쪽)
                                                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 2, y: 2)
                                        }
                                    }
                                )
                                .onTapGesture {
                                    withAnimation(.easeInOut) { selectedTab = idx }
                                }
                        }
                    }
                    .frame(height: 36)  // 전체 높이
                    .background(
                        // 배경 캡슐 + 양쪽 그림자
                        Capsule()
                            .fill(Color.gray.opacity(0.2))
                            .shadow(color: Color.black.opacity(0.15), radius: 4, x: 4, y: 4)
                    )
                    .padding(.horizontal, 24)


                    
                    // MARK: - Gauge
                    GaugeView(score: score)
                        .frame(height: 140)
                        .padding(.horizontal, 24)
                    
                    // MARK: - Legend
                    HStack(alignment: .top, spacing: 8) {
                        Circle()
                            .fill(Color.gray.opacity(0.4))
                            .frame(width: 6, height: 6)
                        Text("객관적 건강 수치 평가 요소\n연령 / 키, 몸무게(BMI) / 현재 질병 상태 및 활력 증대 여부 / 국가건강검진 수치")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 24)
                    
                    // MARK: - Analysis Table
                    VStack(alignment: .leading, spacing: 8) {
                        Text("건강검진 결과 분석")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        HStack(spacing: 16) {
                            AnalysisColumn(title: "주의", items: warningItems)
                            AnalysisColumn(title: "위험", items: warningItems)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal, 24)
                    
                    // MARK: - Summary
                    VStack(alignment: .leading, spacing: 12) {
                        Text("검진 내용 요약")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        ForEach(["복용 약물", "복용 영양제 또는 건기식", "과거력", "가족력"], id: \.self) { title in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(title)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Divider()
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // MARK: - Recommendations
                    VStack(alignment: .leading, spacing: 12) {
                        Text("00님께 딱 맞는 건강기능식품 추천")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        HStack(spacing: 12) {
                            ForEach(0..<3) { _ in
                                RecommendationCard()
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

// MARK: - GaugeView
struct GaugeView: View {
    let score: Int
    var body: some View {
        ZStack {
            // 배경 아크
            Circle()
                .trim(from: 0.0, to: 0.75)
                .rotation(Angle(degrees: 135))
                .stroke(Color.gray.opacity(0.3), lineWidth: 12)
            // 컬러 아크
            Circle()
                .trim(from: 0.0, to: CGFloat(score) / 1000 * 0.75)
                .rotation(Angle(degrees: 135))
                .stroke(Color.blue, style: StrokeStyle(lineWidth: 12, lineCap: .round))
            // 아이콘 + 점수
            VStack(spacing: 4) {
                Image(systemName: "arm.flex.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                Text("\(score)점")
                    .font(.title)
                    .fontWeight(.bold)
            }
        }
    }
}

// MARK: - AnalysisColumn
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

// MARK: - RecommendationCard
struct RecommendationCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // placeholder 이미지
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 80)
                .cornerRadius(8)
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
        .padding(8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
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
        HealthReportView()
    }
}
