import SwiftUI
import PhotosUI

// MARK: - Health Score Main View
struct HealthScoreView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var showCamera = false
    @State private var showActionSheet = false
    @State private var showPhotosPicker = false
    @Bindable var viewModel: HealthScoreViewModel = .init()
    
    var body: some View {
        ScrollView {
            VStack {
                VStack(alignment: .leading) {
                    // Custom Navigation Back Button
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundStyle(.black)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    
                    Spacer().frame(height: 10)
                    
                    // Content
                    HealthHeaderView(title: "내 건강점수를 알아볼까요?")
                    
                    Spacer().frame(height: 110)
                    
                    SurveyButtonView(title: "설문 시작하기") {
                        // 설문 시작 액션
                    }
                    Spacer().frame(minHeight: 10)
                    DescriptionTextView(text: "객관적 건강수치와 주관적 건강 수치 분석을 위한 설문문항으로 구성되었습니다.\n추후 AI 데이터 분석을 위한 자료로 사용할 수 있습니다.\n소요시간 : 00 - 00분")
                    
                    Spacer().frame(height: 50)
                    
                    ImageUploadButtonView(title: "이미지 업로드", systemImage: "camera") {
                        // 업로드 액션
                        showActionSheet = true
                    }
                    Spacer().frame(height: 10)
                    DescriptionTextView(text: "정밀 검사를 원하시는 경우\n건강보험공단 건강검진 결과를 이미지 파일로 업로드 해주세요 (.jpg)")
                    
                }
                
                Spacer().frame(minHeight: 200)
                
                ConfirmButtonView(title: "확인") {
                    // 확인 액션
                }
            }
        }
        .navigationBarBackButtonHidden()
        // Photo source selection
        .confirmationDialog(
            "사진을 어떻게 추가할까요?",
            isPresented: $showActionSheet,
            titleVisibility: .visible
        ) {
            Button("앨범에서 가져오기") { showPhotosPicker = true }
            Button("카메라로 촬영하기") { showCamera = true }
            Button("취소", role: .cancel) {}
        }
        // Camera picker sheet
        .sheet(isPresented: $showCamera) {
            CameraPicker { image in
                viewModel.addImage(image)
            }
        }
        // Photos picker
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
}

// MARK: - RoundedCorner Shape
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

// MARK: - Header View
struct HealthHeaderView: View {
    let title: String

    var body: some View {
        VStack {
            Spacer()
            
            Text(title)
                .font(.system(size: 22, weight: .semibold))
            Spacer().frame(height: 22)
            
        }
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
        .padding(.horizontal, 16)
        .background(Color.gray.opacity(0.3))
        .cornerRadius(12, corners: [.topLeft, .topRight])
    }
}

// MARK: - Survey Button
struct SurveyButtonView: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.3))
                .cornerRadius(12)
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - Description Text
struct DescriptionTextView: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 12))
            .foregroundColor(.gray)
            .multilineTextAlignment(.leading)
            .padding(.horizontal, 12)
    }
}

// MARK: - Image Upload Button
struct ImageUploadButtonView: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                Text(title)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.gray.opacity(0.3))
            .cornerRadius(12)
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - Confirm Button
struct ConfirmButtonView: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.3))
                .cornerRadius(25)
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 32)
    }
}

// MARK: - Preview
struct HealthScoreView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HealthScoreView()
                .environment(NavigationRouter())
        }
    }
}
