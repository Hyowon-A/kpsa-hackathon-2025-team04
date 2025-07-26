import SwiftUI

struct HomeView: View {
    @Environment(NavigationRouter.self) private var router
    // 토글 상태 관리
    @State private var isSurveySelected = false
    @State private var isPreviousReportSelected = false
    @State private var isConsultationSelected = false

    var body: some View {
        VStack(spacing: 24) {
            // MARK: - Top Bar
            HStack {
                Text("yakcare +")
                    .font(.pretendardSemiBold(13))
                    .foregroundColor(.green)
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)

            // MARK: - Reservation Card
            ReservationCardView(
                title: "000님의 예약",
                pharmacyName: "00약국",
                dateText: "2025.8.21.(목) 오전 10:00 에",
                statusText: "예약 되어있어요.",
                address: "주소"
            )

            Spacer().frame(height: 46)
            
            // MARK: - Actions
            VStack(spacing: 55) {
                // 기본 Primary 버튼
                ToggleableButtonView(
                    title: "건강점수 확인하기",
                    isSelected: $isSurveySelected
                ) {
                    // TODO: action
                    router.push(.surveyStep1)
                }
                // 클릭 시 Primary 스타일로 변경되는 토글 버튼
                ToggleableButtonView(
                    title: "이전 레포트 불러오기",
                    isSelected: $isPreviousReportSelected
                ) {
                    // TODO: action
                }
                ToggleableButtonView(
                    title: "약사 상담 요청하기",
                    isSelected: $isConsultationSelected
                ) {
                    // TODO: action
                    router.push(.cornerSelection)
                }
            }
            .padding(.horizontal, 24)

            Spacer()
        }
        .background(Color.white.edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
    }
}

// MARK: - Toggleable Button Component
struct ToggleableButtonView: View {
    let title: String
    @Binding var isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            // 상태 토글 후 동작 수행
            isSelected.toggle()
            action()
        }) {
            Text(title)
                .font(.body)
                .foregroundColor(isSelected ? .green : .black)
                .frame(maxWidth: .infinity)
                .frame(height: 85)
                .background(isSelected ? Color.clear : Color.gray.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.green : Color.clear, lineWidth: 1)
                )
                .cornerRadius(12)
        }
    }
}

// MARK: - Reservation Card Component
struct ReservationCardView: View {
    let title: String
    let pharmacyName: String
    let dateText: String
    let statusText: String
    let address: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.black.opacity(0.7))
            Text(pharmacyName)
                .font(.title2)
                .fontWeight(.bold)
            Text(dateText)
                .font(.subheadline)
            Text(statusText)
                .font(.subheadline)
            HStack(spacing: 4) {
                Image("Location")
                Text(address)
                    .font(.caption)
                Spacer()
            }
        }
        .padding(16)
        .background(Color.green.opacity(0.3))
        .clipShape(RoundedCorner(radius: 16, corners: [.topLeft, .topRight]))
    }
}

fileprivate struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HomeView()
                .environment(NavigationRouter())
        }
    }
}
