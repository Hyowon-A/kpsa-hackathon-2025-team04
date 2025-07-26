//
//  LoginView.swift
//  YakCare+
//
//  Created by 이효주 on 7/26/25.
//

import SwiftUI
import UIKit

struct LoginView: View {
    @Environment(NavigationRouter.self) private var router
    @EnvironmentObject var loginVM: ContentsViewModel
    @State private var email: String = ""
    @State private var password: String = ""
    
    var body: some View {
        VStack {
            Spacer().frame(height: 100)
            
            // 1. 타이틀
            Text("Yakcare +")
                .font(.largeTitle)
                .fontWeight(.semibold)
            
            Spacer().frame(height: 65)
            
            // 2. 로고 플레이스홀더
            Image("Logo")
                .frame(width: 120, height: 120)
            
            Spacer().frame(height: 65)
            
            // 3. 입력 필드
            VStack(spacing: 16) {
                TextField("이메일 또는 전화번호", text: $loginVM.email)
                    .padding()
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(25)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                
                SecureField("비밀번호", text: $loginVM.password)
                    .padding()
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(25)
            }
            .padding(.horizontal, 24)
            
            Spacer().frame(height: 75)
            // 4. 로그인 버튼
            Button(action: {
                // 로그인 처리
                loginVM.loginAndStoreTokens(email: loginVM.email, password: loginVM.password)
            }) {
                Text("로그인")
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(25)
            }
            .padding(.horizontal, 24)
            
            Spacer().frame(height: 25)
            
            // 5. 회원가입 링크
            Button(action: {
                // 회원가입 이동
                router.push(.signup)
            }) {
                Text("Yakcare + 회원가입")
                    .font(.footnote)
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

#Preview {
    @Previewable @StateObject var loginVM = ContentsViewModel()
    
    LoginView()
        .environment(NavigationRouter())
        .environmentObject(loginVM)
}
