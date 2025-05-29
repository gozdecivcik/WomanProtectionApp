import FirebaseAuth
import SwiftUI
import FirebaseCore

// 🔥 Firebase'i UIApplicationDelegate üzerinden başlatıyoruz
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct WomanProtectionApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var appState = AppState()

    var body: some Scene {
            WindowGroup {
                if appState.isLoading {
                    SplashView() // basit bir yükleniyor ekranı göster
                } else {
                    switch appState.currentScreen {
                    case .register:
                        RegisterView().environmentObject(appState)
                    case .login:
                        LoginView().environmentObject(appState)
                    case .profile:
                        ProfileView().environmentObject(appState)
                    case .home:
                        HomeView().environmentObject(appState)
                    }
                }
            }
        }
}
