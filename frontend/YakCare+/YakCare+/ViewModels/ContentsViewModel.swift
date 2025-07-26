
import Foundation
import Moya

final class ContentsViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    
    var userData: UserData?
    let provider: MoyaProvider<UserRotuer>
    let loginProvider: MoyaProvider<AuthRouter>
    
    init(provider: MoyaProvider<UserRotuer> = APIManager.shared.createProvider(for: UserRotuer.self),
             loginProvider: MoyaProvider<AuthRouter> = APIManager.shared.createProvider(for: AuthRouter.self)) {
            self.provider = provider
            self.loginProvider = loginProvider
        }
    
    
    func loginAndStoreTokens(email: String, password: String) {
            loginProvider.request(.login(email: email, password: password)) { result in
                switch result {
                case .success(let response):
                    do {
                        // decode the TokenResponse(accessToken, refreshToken)
                        let tokenData = try JSONDecoder().decode(TokenResponse.self, from: response.data)

                        // store via your KeychainManager
                        let saved = KeychainManager.standard.saveSession(
                            .init(accessToken: tokenData.accessToken, refreshToken: tokenData.refreshToken),
                            for: "appNameUser"
                        )
                        print("✅ Tokens saved:", saved, tokenData)

                    } catch {
                        print("❌ 로그인 응답 디코딩 실패:", error)
                    }

                case .failure(let error):
                    print("❌ 로그인 요청 실패:", error)
                }
            }
        }
    
    
    func getUser() async {
        do {
            let response = try await provider.requestAsync(.getPerson(name: "제옹"))
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(DateFormatter.yyyyMMdd)
            let user = try decoder.decode(UserData.self, from: response.data)
            print("유저", user)
        } catch {
            print("요청 또는 디코딩 실패:", error.localizedDescription)
        }
    }

    
    func createUser(_ userData: UserData) {
        provider.request(.postPerson(userData: userData)) { result in
            switch result {
            case .success(let response):
                do {
                    let res = try JSONDecoder().decode(UserResponse.self, from: response.data)
                    print("✅ POST 응답 메시지:", res.message)
                } catch {
                    print("❌ POST 응답 디코딩 실패:", error)
                }
            case .failure(let error):
                print("❌ POST 실패:", error)
            }
        }
    }
    
    func updateUserPut(_ userData: UserData) {
        provider.request(.putPerson(userData: userData)) { result in
            switch result {
            case .success(let response):
                do {
                    let res = try JSONDecoder().decode(UserResponse.self, from: response.data)
                    print("✅ PUT 응답 메시지:", res.message)
                } catch {
                    print("❌ PUT 디코딩 실패:", error)
                }
            case .failure(let error):
                print("❌ PUT 실패:", error)
            }
        }
    }
    
    func updateUserPatch(_ patchData: UserPatchRequest) {
        provider.request(.patchPerson(patchData: patchData)) { result in
            switch result {
            case .success(let response):
                do {
                    let res = try JSONDecoder().decode(UserResponse.self, from: response.data)
                    print("✅ PATCH 응답 메시지:", res.message)
                } catch {
                    print("❌ PATCH 디코딩 실패:", error)
                }
            case .failure(let error):
                print("❌ PATCH 실패:", error)
            }
        }
    }
    
    func deleteUser(name: String) {
        provider.request(.deletePerson(name: name)) { result in
            switch result {
            case .success(let response):
                do {
                    let res = try JSONDecoder().decode(UserResponse.self, from: response.data)
                    print("✅ DELETE 응답 메시지:", res.message)
                } catch {
                    print("❌ DELETE 디코딩 실패:", error)
                }
            case .failure(let error):
                print("❌ DELETE 실패:", error)
            }
        }
    }
}


extension MoyaProvider {
    func requestAsync(_ target: Target) async throws -> Response {
        try await withCheckedThrowingContinuation { continuation in
            self.request(target) { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: response)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
}
