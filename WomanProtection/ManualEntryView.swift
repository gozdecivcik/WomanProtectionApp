//
//  ManualEntryView.swift
//  WomanProtection
//
//  Created by Gözde Civcik on 18.12.2024.
//
import SwiftUI

struct ManualEntryView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var name: String = ""
    @State private var phoneNumber: String = ""
    var onSave: (EmergencyContact) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Ad Soyad", text: $name)
                TextField("Telefon Numarası", text: $phoneNumber)
                    .keyboardType(.phonePad)
            }
            .navigationBarTitle("Kişi Ekle", displayMode: .inline)
            .navigationBarItems(leading: Button("İptal") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Kaydet") {
                let newContact = EmergencyContact(name: name, phoneNumber: phoneNumber)
                onSave(newContact)
                presentationMode.wrappedValue.dismiss()
            }.disabled(name.isEmpty || phoneNumber.isEmpty))
        }
    }
}

