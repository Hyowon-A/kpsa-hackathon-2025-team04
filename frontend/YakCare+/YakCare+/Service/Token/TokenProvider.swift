
import Foundation
import Moya

class TokenProvider: TokenProviding {
    //  Keychain에 저장할 때, 그리고 꺼낼 때 사용할 키(key) 문자열을 "appNameUser"로 정해둠.
    private let userSession = "appNameUser"
    // .Standard는 앱 전체에서 하나뿐인 키체인매니저 객체를 리턴한다.
    private let keyChain = KeychainManager.standard
    private let provider = MoyaProvider<AuthRouter>()
    
    // accessToken 저장소
    var accessToken: String? {
        get {
            guard let userInfo = keyChain.loadSession(for: userSession) else { return nil }
            return userInfo.accessToken
        }
        set {
            guard var userInfo = keyChain.loadSession(for: userSession) else { return }
            userInfo.accessToken = newValue
            if keyChain.saveSession(userInfo, for: userSession) {
                print("유저 액세스 토큰 갱신됨: \(String(describing: newValue))")
            }
        }
    }
    
    // refreshToken 저장소
    var refreshToken: String? {
        get {
            guard let userInfo = keyChain.loadSession(for: userSession) else { return nil }
            return userInfo.refreshToken
        }
        
        set {
            guard var userInfo = keyChain.loadSession(for: userSession) else { return }
            userInfo.refreshToken = newValue
            if keyChain.saveSession(userInfo, for: userSession) {
                print("유저 리프레시 갱신됨")
            }
        }
    }
    
    func refreshToken(completion: @escaping (String?, (any Error)?) -> Void) {
        guard let userInfo = keyChain.loadSession(for: userSession), let refreshToken = userInfo.refreshToken else {
            // 세션이나 리프레시 토큰이 없으면 에러 콜백 후 바로 종료
            let error = NSError(domain: "example.com", code: -2, userInfo: [NSLocalizedDescriptionKey: "UserSession or refreshToken not found"])
            completion(nil, error)
            return
        }
        
        
        provider.request(.sendRefreshToken(refreshToken: refreshToken)) { result in
            switch result {
            case .success(let response):
                if let jsonString = String(data: response.data, encoding: .utf8) {
                    print("응답 JSON: \(jsonString)")
                } else {
                    print("JSON 데이터를 문자열로 변환할 수 없습니다.")
                }

                do {
                    // JSON 응답 디코딩
                    let tokenData = try JSONDecoder().decode(TokenResponse.self, from: response.data)

                    // 디코딩 성공 후 토큰 저장
                    self.accessToken = tokenData.accessToken
                    self.refreshToken = tokenData.refreshToken

                    completion(self.accessToken, nil)
                } catch {
                    print("디코딩 에러: \(error)")
                    completion(nil, error)
                }

            case .failure(let error):
                print("네트워크 에러 : \(error)")
                completion(nil, error)
            }
        }
    }
    
}
