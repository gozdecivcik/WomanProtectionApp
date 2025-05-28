import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var auth = AuthViewModel()

    @State private var email = ""
    @State private var password = ""
    @State private var showError = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Giriş Yap")
                .font(.largeTitle)
                .bold()

            TextField("E-posta", text: $email)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            SecureField("Parola", text: $password)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            Button("Giriş Yap") {
                auth.login(email: email, password: password) { success, hasProfile in
                    if success {
                        appState.currentScreen = hasProfile ? .home : .profile
                    } else {
                        showError = true
                    }
                }
            }

            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)

            if showError || !auth.errorMessage.isEmpty {
                Text(auth.errorMessage.isEmpty ? "E-posta veya parola yanlış." : auth.errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            Button("Hesabın yok mu? Kayıt ol") {
                appState.currentScreen = .register
            }
            .font(.footnote)
            .foregroundColor(.blue)
            .padding(.top, 10)

        }
        .padding()
    }
}
