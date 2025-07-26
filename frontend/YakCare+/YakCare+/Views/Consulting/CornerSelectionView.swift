import SwiftUI
import PhotosUI

struct ConcernSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(NavigationRouter.self) private var router
    
    private let options = [
        "건강기능 식품을 추천 받고 싶어요",
        "식습관 상담을 받고 싶어요",
        "생활습관 상담을 받고 싶어요",
        "복용중인 약에 대해 묻고 싶어요"
    ]
    
    // 상태
    @State private var selectedIndices: Set<Int> = []
    @State private var customText: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // MARK: - Nav Bar
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.black)
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            
            // MARK: - Title
            VStack(alignment: .leading) {
                Spacer().frame(height: 68)
                
                Text("어떤 고민이 있나요?")
                    .font(.system(size: 28, weight: .bold))
                
                Spacer().frame(height: 14)
                
                Text("약사에게 상담하고 싶은 내용을 골라주세요")
                    .font(.system(size: 16))
                Text("중복 선택이 가능해요")
                    .font(.system(size: 12))
                
                Spacer().frame(height: 40)
            }
            .padding(.horizontal, 16)
            
            // MARK: - Options
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(options.indices, id: \.self) { idx in
                        let isSelected = selectedIndices.contains(idx)
                        Button(action: {
                            if isSelected {
                                selectedIndices.remove(idx)
                            } else {
                                selectedIndices.insert(idx)
                            }
                        }) {
                            Text(options[idx])
                                .font(.system(size: 16))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, minHeight: 60)
                                .background(isSelected
                                            ? Color.gray.opacity(0.3)
                                            : Color.gray.opacity(0.1))
                                .cornerRadius(12)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    
                    // 직접 입력 필드
                    HStack {
                        Image(systemName: "pencil")
                            .foregroundColor(.gray)
                        TextField("직접 적을래요", text: $customText)
                            .foregroundColor(customText.isEmpty ? .gray : .black)
                    }
                    .padding(.horizontal)
                    .frame(height: 60)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
            
            
            Spacer()
            
            // MARK: - Confirm Button
            Button(action: {
                // 확인 액션
                router.push(.nearByPharmacy)
            }) {
                Text("확인")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(25)
            }
            .padding(.horizontal, 16)
        }
        .navigationBarBackButtonHidden()
        .background(Color.white.ignoresSafeArea())
    }
}

struct ConcernSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        ConcernSelectionView()
            .environment(NavigationRouter())
    }
}
