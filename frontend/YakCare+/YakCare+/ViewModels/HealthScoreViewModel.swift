

import Foundation
import SwiftUI
import Vision

@Observable
class HealthScoreViewModel: ImageHandling {
    var images: [UIImage] = []
    
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
    
}
