import FirebaseAuth
import SwiftUI

class AppState: ObservableObject {
    @Published var currentScreen: Screen

    enum Screen {
        case register
        case login
        case profile
        case home
    }

    init() {
        if Auth.auth().currentUser != nil {
            self.currentScreen = .home // Kullanıcı zaten giriş yaptıysa → HomeView
        } else {
            self.currentScreen = .register // Yeni kullanıcı → RegisterView
        }
    }
}
