import SwiftUI
import PhotosUI

struct SurveyStep4View: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(NavigationRouter.self) private var router

    @State private var answer13: Int? = nil
    @State private var answer14: Int? = nil
    @State private var answer15: Int? = nil

    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var showCamera = false
    @State private var showActionSheet = false
    @State private var showPhotosPicker = false
    @Bindable var viewModel: HealthScoreViewModel = .init()
    
    private let options = ["매우 좋음", "좋음", "보통", "나쁨", "매우 나쁨"]

    var body: some View {
        VStack(spacing: 0) {
            // ────────────────────────────────────
            // 1) 상단 진행 바
            SurveyNavBarProgressView(current: 3, total: 3)
                .padding(.bottom, 30)
            
            // 2) 질문 스크롤 영역
            ScrollView {
                VStack(alignment: .leading, spacing: 40) {
                    // 질병 관련 불편감 및 불안
                    Group {
                        Text("질병 관련 불편감 및 불안")
                            .font(.system(size: 16, weight: .semibold))
                        
                        questionView(
                            number: 13,
                            text: "몸의 불편함(통증, 피로, 소화불량 등)을 자주 느끼지 않는 편인가요?",
                            selection: $answer13
                        )
                        questionView(
                            number: 14,
                            text: "질병에 대한 불안은 자주 느끼지 않는 편이신가요?",
                            selection: $answer14
                        )
                        questionView(
                            number: 15,
                            text: "최근 병원 진료를 자주 받는 경험이 없나요?",
                            selection: $answer15
                        )
                    }

                    // 정밀 검사 이미지 업로드
                    VStack(alignment: .leading, spacing: 15) {
                        Text("정밀 검사")
                            .font(.system(size: 16, weight: .semibold))
                        
                        Button {
                            showActionSheet = true
                        } label: {
                            HStack {
                                Image(systemName: "camera")
                                Text("이미지 업로드")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(12)
                        }
                        
                        Text("정밀 검사를 원하는 경우\n건강보험공단 건강검진 결과를 이미지 파일로 업로드 해주세요 (.jpg)")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 80) // 버튼 높이 만큼 여유를 줍니다
            }
            // ────────────────────────────────────
        }
        .padding(.horizontal, 16)
        .navigationBarBackButtonHidden()
        // ────────────────────────────────────
        // 3) 바텀에 고정된 “다음” 버튼
        .safeAreaInset(edge: .bottom) {
            PrimaryButton(title: "다음") {
                router.push(.report)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(UIColor.systemBackground))
        }
        // ────────────────────────────────────
        // Photo 선택/카메라/앨범 처리
        .confirmationDialog("사진을 어떻게 추가할까요?", isPresented: $showActionSheet) {
            Button("앨범에서 가져오기") { showPhotosPicker = true }
            Button("카메라로 촬영하기") { showCamera = true }
            Button("취소", role: .cancel) {}
        }
        .sheet(isPresented: $showCamera) {
            CameraPicker { image in
                viewModel.addImage(image)
            }
        }
        .photosPicker(
            isPresented: $showPhotosPicker,
            selection: $selectedItems,
            maxSelectionCount: 1,
            matching: .images
        )
        .onChange(of: selectedItems) { _, newItems in
            for item in newItems {
                Task {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        viewModel.addImage(image)
                    }
                }
            }
        }
    }

    // 라디오 버튼 질문 뷰 추출
    @ViewBuilder
    private func questionView(
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
struct SurveyStep4View_Previews: PreviewProvider {
    static var previews: some View {
        SurveyStep4View()
            .environment(NavigationRouter())
    }
}
