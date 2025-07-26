import Foundation
import Moya

enum UserRotuer {
    case getPerson(name: String)
    case postPerson(userData: UserData)
    case patchPerson(patchData: UserPatchRequest)
    case putPerson(userData: UserData)
    case deletePerson(name: String)
}

extension UserRotuer: APITargetType {
    var path: String {
      switch self {
      case .getPerson:
        return "/user"            // 회원 조회
      case .postPerson:
        return "/auth/signup"     // 회원가입
      case .patchPerson:
        return "/user/patch"      // 예시
      case .putPerson:
        return "/user/put"        // 예시
      case .deletePerson:
        return "/user/delete"     // 예시
      }
    }

    
    var method: Moya.Method {
        switch self {
        case .getPerson:
            return .get
        case .postPerson:
            return .post
        case .patchPerson:
            return .patch
        case .putPerson:
            return .put
        case .deletePerson:
            return .delete
        }
    }
    
    var task: Task {
        let formatter = DateFormatter.yyyyMMdd
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(formatter)

        switch self {
        case .getPerson(let name), .deletePerson(let name):
            return .requestParameters(parameters: ["name": name], encoding: URLEncoding.queryString)

        case .postPerson(let userData), .putPerson(let userData):
            return .requestCustomJSONEncodable(userData, encoder: encoder)

        case .patchPerson(let patchData):
            return .requestCustomJSONEncodable(patchData, encoder: encoder)
        }
    }
    
    var sampleData: Data {
        let formatter = DateFormatter.yyyyMMdd
        let dob = formatter.date(from: "1995-05-01")!
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(formatter)

        switch self {
        case .getPerson:
            // 유저 데이터 반환
            let sample = UserData(
                email: "sample@email.com",
                password: "password123",
                name: "샘플유저",
                dob: dob,
                gender: "남성",
                occupation: "개발자",
                work_style: "재택"
            )
            return (try? encoder.encode(sample)) ?? Data()

        case .postPerson:
            return (try? encoder.encode(UserResponse(message: "Signup successful"))) ?? Data()

        case .putPerson:
            return (try? encoder.encode(UserResponse(message: "User updated successfully"))) ?? Data()

        case .patchPerson:
            return (try? encoder.encode(UserResponse(message: "User partially updated"))) ?? Data()

        case .deletePerson:
            return (try? encoder.encode(UserResponse(message: "User deleted successfully"))) ?? Data()
        }
    }
}
