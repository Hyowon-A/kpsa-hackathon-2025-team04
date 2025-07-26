

import Foundation
import SwiftUI
import Vision

@Observable
class HealthScoreViewModel: ImageHandling {
    var selectedImage: MemoModel?
    var images: [UIImage] = []
    var ocrResults:[MemoModel] = []
    
    /// ImageHandling 프로토콜을 준수한다. addImage(), getImage()
    func addImage(_ image: UIImage) {
        images.append(image)
        startOCR(image)
    }
    
    func removeImage(at index: Int) {
        guard images.indices.contains(index) else { return }
        images.remove(at: index)
    }
    
    func getImages() -> [UIImage] {
        images
    }
    
    /// OCR 함수
    /// UIImage를 받아서 Core Graphics 이미지(CGImage)로 변환한다.
    func startOCR(_ uiImage: UIImage) {
        guard let cgImage = uiImage.cgImage else {
            self.selectedImage = nil
            return
        }
        
        let request = VNRecognizeTextRequest { [weak self] request, error in
            guard let self = self,
                  let observations = request.results as? [VNRecognizedTextObservation],
                  error == nil else {
                self?.selectedImage = nil
                return
            }

            // 1. 텍스트와 위치정보 추출
            let items: [(text: String, box: CGRect)] = observations.compactMap {
                guard let top = $0.topCandidates(1).first else { return nil }
                return (top.string, $0.boundingBox)
            }

            // 2. y좌표 기준 그룹핑 (줄 나누기)
            let groupedByLine = Dictionary(grouping: items) { item in
                Int(item.box.midY * 100) // y 중심 좌표로 그룹핑
            }

            // 3. 줄 순서 (y 큰 순 → 위에서 아래로), 줄 내 순서 (x 작은 순 → 왼쪽에서 오른쪽으로)
            let sortedLines = groupedByLine
                .sorted { $0.key > $1.key } // y 기준: 위에서 아래로
                .map { $0.value.sorted { $0.box.minX < $1.box.minX } } // x 기준: 왼→오

            // 4. 줄 단위 문자열 생성
            let fullText = sortedLines
                .map { line in line.map { $0.text }.joined(separator: " ") } // 줄 내 문자열
                .joined(separator: "\n") // 줄 구분

            print("===== 왼→오 정렬된 OCR 결과 =====")
            print(fullText)

            let parsed = self.parseWithoutRegex(from: fullText)

            DispatchQueue.main.async {
                self.ocrResults.append(parsed)
            }
        }
        
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        request.recognitionLanguages = ["ko-KR", "en-US"]

        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try? handler.perform([request])
        }
    }

    
    /// OCR 결과 문자열을 파싱하여 MemoModel로 변환한다.
    private func parseWithoutRegex(from text: String) -> MemoModel {
        let lines = text.components(separatedBy: .newlines)

        var bmi: String?
        var bloodPressure: String?
        var fastingGlucose: String?
        var egfr: String?
        var ast: String?
        var alt: String?

        print("===== OCR 디버그 시작 =====")
        for (i, line) in lines.enumerated() {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            print("🔹 [\(i)] \(trimmed)")

            let tokens = trimmed.components(separatedBy: .whitespaces).filter { !$0.isEmpty }

            // BMI
            if bmi == nil, trimmed.contains("체질량지수") || trimmed.uppercased().contains("BMI") {
                bmi = tokens.firstNumberAfter(keyword: "체질량지수")
            }

            // 혈압
            if bloodPressure == nil,
               let match = trimmed.range(of: #"(\d{2,3})\s*/\s*(\d{2,3})"#, options: .regularExpression) {
                bloodPressure = String(trimmed[match])
            }

            // 공복혈당
            if fastingGlucose == nil, trimmed.contains("공복혈당") {
                fastingGlucose = tokens.firstNumberAfter(keyword: "공복혈당")
            }

            // eGFR
            if egfr == nil,
               trimmed.contains("신사구체여과율") || trimmed.uppercased().contains("E-GFR") {
                
                // 같은 줄에서 먼저 시도
                egfr = tokens.firstNumberNear(keyword: "신사구체여과율")
                    ?? tokens.firstNumberNear(keyword: "e-GFR")
                    ?? trimmed.extractFirstNumber()
                
                // 만약 여전히 못 찾았으면 다음 줄도 검사 (163이 다음 줄에 있을 때)
                if (egfr == nil || egfr == "60.0"), i + 1 < lines.count {
                    let nextLine = lines[i + 1].trimmingCharacters(in: .whitespacesAndNewlines)
                    let candidates = nextLine.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
                    egfr = candidates.first(where: { $0.onlyDigitsDots().count >= 2 })?.onlyDigitsDots()
                }
            }


            // AST
            if ast == nil, trimmed.uppercased().contains("AST") {
                ast = tokens.firstNumberAfter(keyword: "AST")
            }

            // ALT
            if alt == nil, trimmed.uppercased().contains("ALT") {
                alt = tokens.firstNumberAfter(keyword: "ALT")
            }
        }

        let resultText = """
        📊 주요 건강 지표

        • BMI: \(bmi ?? "❌")
        • 혈압: \(bloodPressure ?? "❌")
        • 공복혈당: \(fastingGlucose ?? "❌")
        • eGFR: \(egfr ?? "❌")
        • AST: \(ast ?? "❌")
        • ALT: \(alt ?? "❌")
        """

        print("===== 최종 파싱 결과 =====\n\(resultText)")

        return MemoModel(capturedText: resultText)
    }




}

extension String {
    var nonEmpty: String? {
        self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : self
    }
}

extension String {
    func onlyDigitsDots() -> String {
        return self.components(separatedBy: CharacterSet(charactersIn: "0123456789.").inverted).joined()
    }
}

extension Array where Element == String {
    func firstNumberAfter(keyword: String) -> String? {
        guard let keywordIndex = self.firstIndex(where: { $0.contains(keyword) || $0.uppercased().contains(keyword.uppercased()) }) else {
            return nil
        }
        // 키워드 이후 숫자 토큰 찾기
        for i in (keywordIndex + 1)..<self.count {
            let cleaned = self[i].onlyDigitsDots()
            if !cleaned.isEmpty { return cleaned }
        }
        return nil
    }
}

extension Array where Element == String {
    func firstNumberNear(keyword: String) -> String? {
        guard let keywordIndex = self.firstIndex(where: { $0.contains(keyword) || $0.uppercased().contains(keyword.uppercased()) }) else {
            return nil
        }

        let lowerBound = Swift.max(0, keywordIndex - 1)
        let upperBound = Swift.min(self.count - 1, keywordIndex + 3)
        let nearby = (lowerBound...upperBound)

        for i in nearby {
            let cleaned = self[i].onlyDigitsDots()
            if !cleaned.isEmpty { return cleaned }
        }
        return nil
    }
}

extension String {
    func extractFirstNumber() -> String? {
        let matches = self.matches(for: #"(\d+(\.\d+)?)"#)
        return matches.first
    }

    func matches(for regex: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: regex) else { return [] }
        let range = NSRange(startIndex..., in: self)
        return regex.matches(in: self, range: range).compactMap {
            Range($0.range, in: self).map { String(self[$0]) }
        }
    }
}
