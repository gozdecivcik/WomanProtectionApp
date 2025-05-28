//
//  ContactPickerView.swift
//  WomanProtection
//
//  Created by Gözde Civcik on 18.12.2024.
//

import SwiftUI
import ContactsUI

struct ContactPickerView: UIViewControllerRepresentable {
    var onSelect: (EmergencyContact) -> Void
    
    func makeUIViewController(context: Context) -> CNContactPickerViewController {
        let picker = CNContactPickerViewController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: CNContactPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(onSelect: onSelect)
    }
    
    class Coordinator: NSObject, CNContactPickerDelegate {
        var onSelect: (EmergencyContact) -> Void
        
        init(onSelect: @escaping (EmergencyContact) -> Void) {
            self.onSelect = onSelect
        }
        
        func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
            guard let phoneNumber = contact.phoneNumbers.first?.value.stringValue else { return }
            let emergencyContact = EmergencyContact(
                name: "\(contact.givenName) \(contact.familyName)",
                phoneNumber: phoneNumber
            )
            onSelect(emergencyContact)
        }
    }
}
