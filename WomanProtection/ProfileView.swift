//
//  ProfileView.swift
//  WomanProtection
//
//  Created by Gözde Civcik on 22.12.2024.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct ProfileView: View {
    @State private var name: String = ""
    @State private var surname: String = ""
    @State private var birthday: Date = Date()
    @State private var bloodType: String = ProfileView.bloodTypes.first ?? "A+"
    @State private var address: String = ""
    @State private var isSaving: Bool = false
    @State private var showSuccessAlert: Bool = false

    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appState: AppState

    static let bloodTypes = ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"]
    var bloodTypes: [String] { ProfileView.bloodTypes }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Kişisel Bilgiler")) {
                    TextField("Ad", text: $name)
                    TextField("Soyad", text: $surname)

                    DatePicker("Doğum Tarihi", selection: $birthday, displayedComponents: .date)

                    Picker("Kan Grubu", selection: $bloodType) {
                        ForEach(bloodTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }

                    VStack(alignment: .leading) {
                        Text("Adres")
                            .font(.headline)
                        TextEditor(text: $address)
                            .frame(height: 100)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5)))
                    }
                }

                if isSaving {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }
            }
            .navigationTitle("Profil")
            .navigationBarItems(
                leading: Button("İptal") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Kaydet") {
                    saveData()
                }
            )
            .alert(isPresented: $showSuccessAlert) {
                Alert(
                    title: Text("Başarılı!"),
                    message: Text("Bilgileriniz kaydedildi."),
                    dismissButton: .default(Text("Tamam")) {
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            }
        }
    }

    func loadData() {
        if let userData = UserDefaults.standard.dictionary(forKey: "kullaniciBilgileri") as? [String: String] {
            name = userData["ad"] ?? ""
            surname = userData["soyad"] ?? ""

            if let birthdayString = userData["dogumTarihi"],
               let date = ISO8601DateFormatter().date(from: birthdayString) {
                birthday = date
            }

            let gelenKanGrubu = userData["kanGrubu"] ?? ""
            bloodType = bloodTypes.contains(gelenKanGrubu) ? gelenKanGrubu : bloodTypes.first ?? "A+"
            address = userData["adres"] ?? ""
        }
    }

    func saveData() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("❌ Kullanıcı bulunamadı.")
            return
        }

        let isoFormatter = ISO8601DateFormatter()
        let birthdayString = isoFormatter.string(from: birthday)

        let userData: [String: Any] = [
            "name": name,
            "surname": surname,
            "birthday": birthdayString,
            "bloodType": bloodType,
            "address": address
        ]

        print("👉 Kaydedilecek Veriler: \(userData)")

        isSaving = true

        let db = Firestore.firestore()
        db.collection("users").document(userID).setData(userData) { error in
            isSaving = false

            if let error = error {
                print("🔥 Firestore HATASI:", error.localizedDescription)
            } else {
                print("✅ Kullanıcı Firestore'a başarıyla kaydedildi.")
                showSuccessAlert = true
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView().environmentObject(AppState())
    }
}
