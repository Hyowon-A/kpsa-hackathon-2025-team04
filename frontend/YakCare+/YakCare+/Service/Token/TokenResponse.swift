
import Foundation

struct TokenResponse: Codable {
    var accessToken: String
    var refreshToken: String?
}
