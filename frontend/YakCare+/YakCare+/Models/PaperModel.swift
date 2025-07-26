//
//  PaperModel.swift
//  YakCare+
//
//  Created by 이효주 on 7/27/25.
//

import Foundation
import SwiftData

@Model
class PaperModel {
    @Attribute(.unique) var id: UUID
    
    var capturedText: String = "" // 변환된 텍스트
    var createdAt: Date // 생성된 날짜(스위프트 데이터 순)
    
    init (
        capturedText: String,
        createdAt: Date = Date()
    ) {
        self.id = UUID()
        self.capturedText = capturedText
        self.createdAt = createdAt
    }
}
