import Foundation
import Moya

final class SignupViewModel: ObservableObject {
    // 사용자 입력값들
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var name: String = ""
    @Published var dob: Date = Date()
    @Published var gender: String = ""
    @Published var occupation: String = ""
    @Published var workStyle: String = ""

    @Published var userData: UserData?
    let provider: MoyaProvider<UserRotuer>
    let loginProvider: MoyaProvider<AuthRouter>

    init(
        provider: MoyaProvider<UserRotuer> = APIManager.shared.createProvider(for: UserRotuer.self),
        loginProvider: MoyaProvider<AuthRouter> = APIManager.shared.createProvider(for: AuthRouter.self)
    ) {
        self.provider = provider
        self.loginProvider = loginProvider
    }

    func loginAndStoreTokens(email: String, password: String) {
        loginProvider.request(.login(email: email, password: password)) { result in
            switch result {
            case .success(let response):
                do {
                    let tokenResponse = try JSONDecoder()
                        .decode(TokenResponse.self, from: response.data)
                    KeychainManager.standard.saveSession(
                        .init(
                            accessToken: tokenResponse.accessToken,
                            refreshToken: tokenResponse.refreshToken
                        ),
                        for: "appNameUser"
                    )
                    print("✅ Tokens saved")
                } catch {
                    print("❌ 토큰 디코딩 실패:", error)
                }
            case .failure(let error):
                print("❌ 로그인 요청 실패:", error)
            }
        }
    }
    
    func createUser(_ user: UserData) {
        print("📤 회원가입 요청 데이터:")
        print("- email: \(user.email)")
        print("- password: \(user.password)")
        print("- name: \(user.name)")
        print("- dob: \(user.dob)")
        print("- gender: \(user.gender)")
        print("- occupation: \(user.occupation)")
        print("- work_style: \(user.work_style)")
        
        provider.request(.postPerson(userData: user)) { [weak self] result in
            switch result {
            case .success(let response):
                print("✅ 회원가입 HTTP \(response.statusCode)")
                print("🗂 Response Headers:", response.response?.allHeaderFields ?? [:])
                print("📦 Response Body:\n", String(data: response.data, encoding: .utf8) ?? "")
                do {
                    let decoded = try JSONDecoder().decode(UserResponse.self, from: response.data)
                    print("✅ 회원가입 성공: \(decoded.message)")
                    DispatchQueue.main.async {
                        self?.userData = user
                    }
                } catch {
                    print("❌ 회원가입 응답 디코딩 실패: \(error)")
                }

            case .failure(let error):
                print("❌ 회원가입 요청 실패: \(error.localizedDescription)")
            }
        }
    }
}
