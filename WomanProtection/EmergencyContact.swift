//
//  EmergencyContact.swift
//  WomanProtection
//
//  Created by Gözde Civcik on 18.12.2024.
//

struct EmergencyContact: Identifiable {
    let id: String // Firestore document ID
    let name: String
    let phoneNumber: String
    var isFavorite: Bool
}


