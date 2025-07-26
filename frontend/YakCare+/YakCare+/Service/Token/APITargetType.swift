//
//  APITarget.swift
//  Bookmark
//
//  Created by 이효주 on 7/25/25.
//

import Foundation
import Moya

protocol APITargetType: TargetType {}

extension APITargetType {
    var baseURL: URL {
        return URL(string: "https://kpsa-hackathon-2025-team04.onrender.com")!
    }

    /// JSON 요청일 땐 Content-Type: application/json
    ///파일 업로드일 땐 Content-Type: multipart/form-data
    ///그 외는 nil (헤더 미설정)
    var headers: [String:String]? {
        switch task {
        case .requestJSONEncodable,
             .requestParameters,
             .requestCustomJSONEncodable:   // 여기 추가!
          return ["Content-Type": "application/json"]
        case .uploadMultipart:
          return ["Content-Type": "multipart/form-data"]
        default:
          return nil
        }
      }
    
    // HTTP 상태 코드 중 200~299를 “성공”으로 간주
    var validationType: ValidationType { .successCodes }
}
