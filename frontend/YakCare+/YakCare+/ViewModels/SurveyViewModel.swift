import Combine

class SurveyViewModel: ObservableObject {
    // 총 15개 문항의 답변을 0번부터 14번 인덱스로 관리
    @Published var answers: [SurveyAnswer] =
        (1...15).map { SurveyAnswer(questionNumber: $0, selectionIndex: nil) }
    @Published var medications: [String] = []
    @Published var supplements: [String] = []
    @Published var pastConditions: [String] = []
    @Published var familyHistory: [String] = []

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

struct SubjectiveScorePayload: Encodable {
    let overall_health_aware: Int
    let daily_function: Int
    let life_pattern: Int
    let mental: Int
    let inconvenience_concern: Int
    let subjective_score: Int

    init(from viewModel: SurveyViewModel) {
        self.overall_health_aware = viewModel.step1Score  // 1~3
        self.daily_function = viewModel.step2Score         // 4~6
        self.life_pattern = viewModel.step3Score           // 7~9
        self.mental = viewModel.step4Score                 // 10~12
        self.inconvenience_concern = viewModel.step5Score  // 13~15
        self.subjective_score = viewModel.totalScore
    }
}
