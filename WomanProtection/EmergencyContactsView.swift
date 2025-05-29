import SwiftUI
import Contacts
import ContactsUI
import FirebaseFirestore
import FirebaseAuth

struct EmergencyContactsView: View {
    @State private var contacts: [EmergencyContact] = []
    @State private var showingContactPicker = false
    @State private var showingManualEntry = false

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(contacts.indices, id: \.self) { index in
                        let contact = contacts[index]
                        HStack {
                            VStack(alignment: .leading) {
                                HStack {
                                    Text(contact.name)
                                        .font(.headline)
                                    if contact.isFavorite {
                                        Image(systemName: "star.fill")
                                            .foregroundColor(.yellow)
                                    }
                                }
                                Text(contact.phoneNumber)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                deleteContact(at: IndexSet(integer: index))
                            } label: {
                                Label("Sil", systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                toggleFavorite(index: index)
                            } label: {
                                Label("Favori", systemImage: "star")
                            }
                            .tint(.yellow)
                        }
                    }
                }


                HStack {
                    Button(action: {
                        showingContactPicker = true
                    }) {
                        HStack {
                            Image(systemName: "person.crop.circle.badge.plus")
                            Text("Rehberden Ekle")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .sheet(isPresented: $showingContactPicker) {
                        ContactPickerView { selectedContact in
                            addContact(selectedContact)
                        }
                    }

                    Button(action: {
                        showingManualEntry = true
                    }) {
                        HStack {
                            Image(systemName: "plus")
                            Text("Manuel Ekle")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .sheet(isPresented: $showingManualEntry) {
                        ManualEntryView { newContact in
                            addContact(newContact)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Acil Kişiler")
        }
        .onAppear(perform: fetchContactsFromFirestore)
    }

    func addContact(_ contact: EmergencyContact) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(userID).collection("emergencyContacts")
            .addDocument(data: [
                "name": contact.name,
                "phoneNumber": contact.phoneNumber,
                "isFavorite": false
            ]) { error in
                if let error = error {
                    print("🔥 Kişi kaydedilemedi: \(error.localizedDescription)")
                } else {
                    fetchContactsFromFirestore()
                }
            }
    }

    func fetchContactsFromFirestore() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()

        db.collection("users").document(userID).collection("emergencyContacts").getDocuments { snapshot, error in
            if let error = error {
                print("🔥 Firestore'dan kişiler çekilemedi: \(error.localizedDescription)")
                return
            }
            guard let documents = snapshot?.documents else { return }

            self.contacts = documents.map {
                EmergencyContact(
                    name: $0["name"] as? String ?? "",
                    phoneNumber: $0["phoneNumber"] as? String ?? "",
                    isFavorite: $0["isFavorite"] as? Bool ?? false
                )
            }
        }
    }
    func toggleFavorite(index: Int) {
        var contact = contacts[index]
        contact.isFavorite.toggle()
        contacts[index] = contact

        guard let userID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let contactRef = db.collection("users").document(userID).collection("emergencyContacts")

        // Mevcut kaydı güncelle (document ID UUID değilse özel logic gerekir!)
        contactRef.whereField("phoneNumber", isEqualTo: contact.phoneNumber).getDocuments { snapshot, error in
            if let document = snapshot?.documents.first {
                document.reference.updateData(["isFavorite": contact.isFavorite])
            }
        }
    }


    func deleteContact(at offsets: IndexSet) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()

        offsets.forEach { index in
            let contact = contacts[index]
            db.collection("users").document(userID).collection("emergencyContacts").document(contact.id.uuidString).delete { error in
                if let error = error {
                    print("🔥 Kişi silinemedi: \(error.localizedDescription)")
                }
            }
        }
        contacts.remove(atOffsets: offsets)
    }
}
