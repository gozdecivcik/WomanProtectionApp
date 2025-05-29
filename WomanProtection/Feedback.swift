//
//  Feedback.swift
//  WomanProtection
//
//  Created by Zeynep on 29.05.2025.
//

import Foundation
import UIKit

struct Feedback: Identifiable {
    var id: String
    var feedbackText: String
    var latitude: Double?
    var longitude: Double?
    var imageBase64: String?
    var timestamp: Date?

    var uiImage: UIImage? {
        guard let base64 = imageBase64,
              let data = Data(base64Encoded: base64) else { return nil }
        return UIImage(data: data)
    }
}

