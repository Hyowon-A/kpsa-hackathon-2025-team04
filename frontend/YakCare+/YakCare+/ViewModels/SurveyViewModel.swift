import Combine

class SurveyViewModel: ObservableObject {
    // 총 15개 문항의 답변을 0번부터 14번 인덱스로 관리
    @Published var answers: [SurveyAnswer] =
        (1...15).map { SurveyAnswer(questionNumber: $0, selectionIndex: nil) }

    // 특정 문항(1~15)의 점수 반환
    func score(for question: Int) -> Int {
        guard (1...15).contains(question) else { return 0 }
        return answers[question - 1].score
    }

    // 스텝2(1~6번) 점수 합
    var step1Score: Int {
        (1...3).reduce(0) { $0 + score(for: $1) }
    }
    
    var step2Score: Int {
        (4...6).reduce(0) { $0 + score(for: $1) }
    }
    
    // 스텝3(7~12번) 점수 합
    var step3Score: Int {
        (7...9).reduce(0) { $0 + score(for: $1) }
    }
    
    var step4Score: Int {
        (10...12).reduce(0) { $0 + score(for: $1) }
    }
    
    // 스텝4(13~15번) 점수 합
    var step5Score: Int {
        (13...15).reduce(0) { $0 + score(for: $1) }
    }


    // 전체 합산 점수
    var totalScore: Int {
        answers.map(\.score).reduce(0, +)
    }
}
