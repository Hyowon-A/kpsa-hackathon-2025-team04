//
//  SurveyResponse.swift
//  YakCare+
//
//  Created by 이효주 on 7/27/25.
//

import Foundation

struct SurveyResponse: Decodable {
    let gpt_recommendations: [String]
    let message: String
    let supplement_list: SupplementList
    let total_score: TotalScore
    let username: String
}

struct SupplementList: Decodable {
    let recommended_ingredients: [String]
    let supplements: [Supplement]
}

struct Supplement: Decodable {
    let efficacy: String
    let image_url: String
    let manufacturer: String
    let name: String
    let price: String
}

struct TotalScore: Decodable {
    let conditions: [String: String]
    let family_history: [String]
    let medications: [String]
    let past_conditions: [String]
    let score: Int
    let supplements: [String]
}
