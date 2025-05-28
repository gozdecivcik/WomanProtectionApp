import FirebaseAuth
import FirebaseFirestore
import Foundation

class AuthViewModel: ObservableObject {
    @Published var errorMessage: String = ""

    func register(name: String, email: String, password: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }

    func login(email: String, password: String, completion: @escaping (Bool, Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    completion(false, false)
                } else {
                    // Firestore'da profil var mı kontrol et
                    guard let uid = result?.user.uid else {
                        completion(true, false)
                        return
                    }
                    let docRef = Firestore.firestore().collection("users").document(uid)
                    docRef.getDocument { snapshot, error in
                        let hasProfile = snapshot?.exists ?? false
                        completion(true, hasProfile)
                    }
                }
            }
        }
    }
}

