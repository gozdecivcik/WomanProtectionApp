import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var auth = AuthViewModel()

    @State private var email = ""
    @State private var password = ""
    @State private var showError = false
    @State private var isLoading = false


    var body: some View {
        VStack(spacing: 20) {
            Text("Giriş Yap")
                .font(.largeTitle)
                .bold()

            TextField("E-posta", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .customTextFieldStyle()
                .padding(.horizontal)

            SecureField("Parola", text: $password)
                .customTextFieldStyle()
                .padding(.horizontal)

            Button(action: {
                isLoading = true
                auth.login(email: email, password: password) { success, hasProfile in
                    isLoading = false
                    if success {
                        appState.currentScreen = hasProfile ? .home : .profile
                    } else {
                        showError = true
                    }
                }
            }) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(maxWidth: .infinity)
                        .padding()
                } else {
                    Text("Giriş Yap")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)
            .disabled(isLoading)


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
