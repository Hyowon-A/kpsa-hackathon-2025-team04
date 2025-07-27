//
//  HealthSurveyRequest.swift
//  YakCare+
//
//  Created by 이효주 on 7/27/25.
//

import Foundation

struct HealthSurveyRequest: Codable {
    // 주관적 건강 평가
    let overall_health_aware: Int
    let daily_function: Int
    let life_pattern: Int
    let mental: Int
    let inconvenience_concern: Int
    let subjective_score: Int

    // 복용, 병력, 가족력
    let medications: [String]
    let supplements: [String]
    let past_conditions: [String]
    let family_history: [String]

    // 객관적 건강 수치
    let systolic: Int?
    let diastolic: Int?
    let fasting_glucose: Int?
    let bmi: Int?
    let ast: Int?
    let alt: Int?
    let egfr: Int?
    let hemoglobin: Double?

    // 기타
    let upload: Bool
}
