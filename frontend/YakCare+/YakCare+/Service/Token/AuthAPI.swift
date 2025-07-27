
import Foundation
import Moya
import SwiftUI

enum AuthRouter {
    case login(email: String, password: String)
    case sendRefreshToken(refreshToken: String)
    case submitSurvey(request: HealthSurveyRequest)
}

extension AuthRouter: APITargetType {
    var baseURL: URL { URL(string: "https://kpsa-hackathon-2025-team04.onrender.com")! }

    var path: String {
        switch self {
        case .login:               return "/auth/login"
        case .sendRefreshToken:    return "/auth/refresh"
        case .submitSurvey:
            return "/survey/result"
        }
    }

    var method: Moya.Method {
        switch self {
        case .login:               return .post
        case .sendRefreshToken:    return .get
        case .submitSurvey:
            return .post
        }
    }

    var task: Task {
        switch self {
        case let .login(email, password):
            // send credentials as JSON
            return .requestParameters(
                parameters: ["email": email, "password": password],
                encoding: JSONEncoding.default
            )
        case let .sendRefreshToken(token):
            return .requestParameters(
                parameters: ["refreshToken": token],
                encoding: URLEncoding.queryString
            )
        case let .submitSurvey(request):
                    return .requestJSONEncodable(request)
        }
    }

    var headers: [String: String]? {
        ["Content-Type": "application/json"]
    }
}
