

import Foundation
import SwiftUI
import Vision

@Observable
class HealthScoreViewModel: ImageHandling {
    var selectedImage: PaperModel?
    var images: [UIImage] = []
    var ocrResults: [PaperModel] = []
    
    /// ImageHandling 프로토콜을 준수한다. addImage(), getImage()
    func addImage(_ image: UIImage) {
        images.append(image)
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
        
        /// request를 약한 참조로 받아 순환 참조를 방지한다.
        /// 결과를 VNRecognizedTextobservation 배열로 캐스팅한다.
        let request = VNRecognizeTextRequest { [weak self] request, error in
            guard let self = self,
                  let observations = request.results as? [VNRecognizedTextObservation],
                  error == nil else {
                self?.selectedImage = nil
                return
            }
            
            /// obsrvation에서 가장 높은 신뢰도의 텍스트 후보를 선택해 문자열 배열로 만든다.
            /// 줄바꿈으로 연결하여 하나의 전체 텍스트 문자열로 만든다.
            let recognizedStrings = observations.compactMap { $0.topCandidates(1).first?.string }
            let fullText = recognizedStrings.joined(separator: "\n")
            let parsed = self.parseWithoutRegex(from: fullText)
            
            DispatchQueue.main.async {
                self.ocrResults.append(parsed)
            }
        }
        
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true // 오타나 문법 보정 활성화
        request.recognitionLanguages = ["ko-KR", "en-US"] // 지원 언어
        
        /// 백그라운드 스레드에서 OCR request를 실행한다.
        /// VNImageRequestHandler는 cgImage에 대해 OCR 요청을 수행하는 핸들러다.
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try? handler.perform([request])
        }
    }
    
    /// OCR 결과 문자열을 파싱하여 MemoModel로 변환한다.
    private func parseWithoutRegex(from text: String) -> PaperModel {
        let lines = text.components(separatedBy: .newlines) // 받은 text를 엔터를 기준으로 나눠서 문자열 배열 lines로 만든다.
        
        // 디버깅용 i
        var i = 0
        
        print("===== OCR 디버그 시작 =====")
                
        while i < lines.count {
            let trimmed = lines[i].trimmingCharacters(in: .whitespacesAndNewlines) // trimmingCharacters로 앞뒤 공백 및 줄바꿈 문자 제거
            print("🔹 [\(i)] \(trimmed)")
            i += 1
        }
        
        return PaperModel(capturedText: text.isEmpty ? "텍스트가 없습니다." : text)
    }
}
