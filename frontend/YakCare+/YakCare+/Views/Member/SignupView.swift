//
//  SignupView.swift
//  YakCare+
//
//  Created by 이효주 on 7/26/25.
//

import SwiftUI
// MARK: - Signup View
struct SignupView: View {
    @Environment(NavigationRouter.self) private var router
    @EnvironmentObject var signupVM: SignupViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var birth = ""
    @State private var gender = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Spacer().frame(height: 30)
                
                ProfileImageView()

                InputField(title: "이메일", placeholder: "이메일 입력", text: $signupVM.email)
                SecureInputField(title: "비밀번호", placeholder: "비밀번호 입력", text: $signupVM.password)
                InputField(title: "이름", placeholder: "이름 입력", text: $signupVM.name)
                // 기존 @State private var birth = "" 제거

                InputField(
                    title: "생년월일",
                    placeholder: "예: 2003-08-05",
                    text: Binding(
                        get: {
                            let formatter = DateFormatter()
                            formatter.dateFormat = "yyyy-MM-dd"
                            return formatter.string(from: signupVM.dob)
                        },
                        set: { newValue in
                            let formatter = DateFormatter()
                            formatter.dateFormat = "yyyy-MM-dd"
                            if let date = formatter.date(from: newValue) {
                                signupVM.dob = date
                            }
                        }
                    )
                )

                GenderSelectionView(selectedGender: $signupVM.gender)
                
                PrimaryButton(title: "다음") {
                    // 회원가입 페이지 2로 이동
                    router.push(.signup2)
                }
                .padding(.top, 16)
            }
            .padding(.horizontal, 16)
        }
        .customNavigation(
            title: "회원가입",
            leading: Button(action: { dismiss() }) {
                Image("leftChevron_small")
                    .fixedSize()
            }
        )
        .navigationBarBackButtonHidden()
    }
}

// MARK: - Generic Input Field
struct InputField: View {
    let title: String?
    let placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title ?? "")
                .font(.system(size: 14))
            TextField(placeholder, text: $text)
                .padding()
                .background(Color.gray.opacity(0.3))
                .cornerRadius(12)
                .autocapitalization(.none)
                .disableAutocorrection(true)
        }
    }
}

// MARK: - Secure Input Field
struct SecureInputField: View {
    let title: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14))
            SecureField(placeholder, text: $text)
                .padding()
                .background(Color.gray.opacity(0.3))
                .cornerRadius(12)
        }
    }
}

// MARK: - Gender Selection
struct GenderSelectionView: View {
    @Binding var selectedGender: String
    private let options = ["남성", "여성"]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("성별")
                .font(.system(size: 14))
            HStack(spacing: 8) {
                ForEach(options, id: \ .self) { gender in
                    Button(action: { selectedGender = gender }) {
                        Text(gender)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .background(selectedGender == gender ? Color.blue.opacity(0.2) : Color.gray.opacity(0.3))
                    .cornerRadius(12)
                }
            }
        }
    }
}

// MARK: - Primary Button
struct PrimaryButton: View {
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
    }
}


// MARK: - ProfileImageView
/// 프로필 이미지 표시 및 수정 기능을 제공하는 뷰
struct ProfileImageView: View {
    // 카메라 메뉴 (수정/삭제) 표시 여부
    @State private var showCameraMenu = false
    // 이미지 피커 시트 표시 여부
    @State private var showImagePicker = false
    // 선택된 이미지 저장
    @State private var selectedImage: UIImage? = nil

    var body: some View {
        HStack {
            Spacer()
            ZStack {
                Group {
                    if let img = selectedImage {
                        // 사용자가 선택한 이미지를 원본 비율 유지하며 표시
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                    } else {
                        // 기본 프로필 이미지 표시
                        Image("Logo_Circle")
                            .resizable()
                            .scaledToFill()
                    }
                }
                .frame(width: 100, height: 100)
                .clipShape(Circle())          // 원형 마스크 적용

                Button(action: {
                    // 애니메이션과 함께 카메라 메뉴 토글
                    withAnimation(.easeInOut) {
                        showCameraMenu.toggle()
                    }
                }) {
                    Image("camera")
                        .resizable()
                        .frame(width: 48, height: 48)
                }
                .offset(x: 35, y: 35)
                .zIndex(1)
            }
            .overlay(
                // 카메라 메뉴: 프로필 수정/삭제 옵션
                Group {
                    if showCameraMenu {
                        VStack(spacing: 0) {
                            Button(action: {
                                showCameraMenu = false
                                showImagePicker = true    // 이미지 피커 호출
                            }) {
                                Text("프로필 수정")
                                    .font(.pretendardRegular(10))
                                    .padding(7)
                                    .frame(maxWidth: .infinity)
                            }
                            Button(action: {
                                selectedImage = nil        // 이미지 삭제
                                showCameraMenu = false
                            }) {
                                Text("프로필 삭제")
                                    .font(.pretendardRegular(10))
                                    .padding(7)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(6)
                        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)
                        .frame(width: 90)
                        .offset(x: 60, y: 50)
                        .zIndex(2)
                        .foregroundStyle(.black)
                    }
                },
                alignment: .bottomTrailing
            )
            Spacer()
        }
        // 이미지 피커 시트 연결
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage)
        }
    }
}

#Preview {
    @Previewable @StateObject var signupVM = SignupViewModel()
    
    NavigationStack {
        SignupView()
            .environment(NavigationRouter())
            .environmentObject(signupVM)
    }
}
