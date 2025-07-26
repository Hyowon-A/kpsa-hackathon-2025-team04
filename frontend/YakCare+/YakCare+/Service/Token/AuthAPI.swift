
import Foundation
import Moya
import SwiftUI

enum AuthRouter {
    case login(email: String, password: String)
    case sendRefreshToken(refreshToken: String)
}

extension AuthRouter: APITargetType {
    var baseURL: URL { URL(string: "https://kpsa-hackathon-2025-team04.onrender.com")! }

    var path: String {
        switch self {
        case .login:               return "/auth/login"
        case .sendRefreshToken:    return "/auth/refresh"
        }
    }

    var method: Moya.Method {
        switch self {
        case .login:               return .post
        case .sendRefreshToken:    return .get
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
        }
    }

    var headers: [String: String]? {
        ["Content-Type": "application/json"]
    }
}
