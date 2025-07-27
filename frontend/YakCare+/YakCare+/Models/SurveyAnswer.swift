//
//  SurveyAnswer.swift
//  YakCare+
//
//  Created by 이효주 on 7/27/25.
//

import Foundation

struct SurveyAnswer {
    let questionNumber: Int   // 1~15
    var selectionIndex: Int?  // 사용자가 고른 옵션의 인덱스(0…4)
    
    // 인덱스를 점수(4,3,2,1,0)로 매핑
    private static let scoreMapping = [4, 3, 2, 1, 0]
    var score: Int {
        guard let idx = selectionIndex,
              SurveyAnswer.scoreMapping.indices.contains(idx)
        else { return 0 }
        return SurveyAnswer.scoreMapping[idx]
    }
}
