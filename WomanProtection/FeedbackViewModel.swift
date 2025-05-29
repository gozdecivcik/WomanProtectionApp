//
//  FeedbackViewModel.swift
//  WomanProtection
//
//  Created by Zeynep on 29.05.2025.
//

import Foundation
import FirebaseFirestore

class FeedbackViewModel: ObservableObject {
    @Published var feedbacks: [Feedback] = []

    func fetchFeedbacks() {
        let db = Firestore.firestore()
        db.collectionGroup("feedbacks").getDocuments { snapshot, error in
            if let error = error {
                print("⚠️ Feedback verileri alınamadı: \(error.localizedDescription)")
                return
            }

            self.feedbacks = snapshot?.documents.compactMap { doc in
                let data = doc.data()
                return Feedback(
                    id: doc.documentID,
                    feedbackText: data["feedbackText"] as? String ?? "",
                    latitude: data["latitude"] as? Double,
                    longitude: data["longitude"] as? Double,
                    imageBase64: data["imageBase64"] as? String,
                    timestamp: (data["timestamp"] as? Timestamp)?.dateValue()
                )
            } ?? []
        }
    }
}

