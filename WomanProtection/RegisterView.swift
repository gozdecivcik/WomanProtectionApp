import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var auth = AuthViewModel()

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var showSuccessAlert = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Kayıt Ol")
                .font(.largeTitle)
                .bold()

            TextField("Adınız", text: $name)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            TextField("E-posta", text: $email)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding(.horizontal)

            SecureField("Şifre", text: $password)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            Button("Kayıt Ol") {
                auth.register(name: name, email: email, password: password) { success in
                    if success {
                        showSuccessAlert = true
                    }
                }
            }
            .alert(isPresented: $showSuccessAlert) {
                Alert(
                    title: Text("Kayıt Başarılı"),
                    message: Text("Lütfen giriş yaparak devam edin."),
                    dismissButton: .default(Text("Giriş Yap")) {
                        appState.currentScreen = .login
                    }
                )
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)

            if !auth.errorMessage.isEmpty {
                Text(auth.errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Button("Zaten hesabın var mı? Giriş yap") {
                appState.currentScreen = .login
            }
            .padding(.top)
        }
        .padding()
    }
}
