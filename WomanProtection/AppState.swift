import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class AppState: ObservableObject {
    @Published var currentScreen: Screen = .login

    enum Screen {
        case register
        case login
        case profile
        case home
    }

    init() {
        if let user = Auth.auth().currentUser {
            let docRef = Firestore.firestore().collection("users").document(user.uid)
            docRef.getDocument { snapshot, _ in
                DispatchQueue.main.async {
                    if snapshot?.exists == true {
                        self.currentScreen = .home
                    } else {
                        self.currentScreen = .profile
                    }
                }
            }
            self.currentScreen = .login // geçici, async biterken görünürlük için
        } else {
            self.currentScreen = .register
        }
    }

    func checkIfProfileExists() {
        guard let userID = Auth.auth().currentUser?.uid else {
            self.currentScreen = .login
            return
        }

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userID)

        userRef.getDocument { document, error in
            DispatchQueue.main.async {
                if let document = document, document.exists {
                    self.currentScreen = .home
                } else {
                    self.currentScreen = .profile
                }
            }
        }
    }
}

    
