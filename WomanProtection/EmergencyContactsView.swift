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
                    ForEach(contacts) { contact in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(contact.name)
                                    .font(.headline)
                                Text(contact.phoneNumber)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .onDelete(perform: deleteContact)
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
                "phoneNumber": contact.phoneNumber
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
                EmergencyContact(name: $0["name"] as? String ?? "", phoneNumber: $0["phoneNumber"] as? String ?? "")
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
