import Foundation

struct UserData: Codable {
    let email: String
    let password: String
    let name: String
    let dob: Date
    let gender: String
    let occupation: String
    let work_style: String

    enum CodingKeys: String, CodingKey {
        case email, password, name, dob, gender, occupation, work_style
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(email, forKey: .email)
        try container.encode(password, forKey: .password)
        try container.encode(name, forKey: .name)
        try container.encode(dob, forKey: .dob)
        try container.encode(gender, forKey: .gender)
        try container.encode(occupation, forKey: .occupation)
        try container.encode(work_style, forKey: .work_style)
    }
}


struct UserPatchRequest: Codable {
    let email: String?
    let password: String?
    let name: String?
    let dob: Date?   // ← 여기!
    let gender: String?
    let occupation: String?
    let work_style: String?
}
