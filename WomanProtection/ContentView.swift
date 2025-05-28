import SwiftUI

struct ContentView: View {
    @State private var name: String = ""
    @State private var surname: String = ""
    @State private var birthday: Date = Date()
    @State private var bloodType: String = ""
    @State private var address: String = ""
    @State private var password: String = ""
    @State private var navigateToLogin: Bool = false
    
    let bloodTypes = ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"]
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Kişisel Bilgiler")) {
                        TextField("Ad", text: $name)
                        TextField("Soyad", text: $surname)
                        DatePicker("Doğum Tarihi", selection: $birthday, displayedComponents: .date)
                        
                        Picker("Kan Grubu", selection: $bloodType) {
                            ForEach(bloodTypes, id: \.self) { type in
                                Text(type)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        
                        TextField("İkametgah Adresi", text: $address)
                        SecureField("Parola", text: $password) // Parola Alanı
                    }
                }
                
                Button(action: {
                    saveData()
                    navigateToLogin = true
                }) {
                    Text("Kaydet ve Devam Et")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(name.isEmpty || surname.isEmpty || bloodType.isEmpty || address.isEmpty || password.isEmpty)
                .padding()
                
                NavigationLink("", destination: LoginView(), isActive: $navigateToLogin)
                    .hidden()
            }
            .navigationTitle("Kayıt Ol")
        }
    }
    
    func saveData() {
        let userData = [
            "ad": name,
            "soyad": surname,
            "doğumTarihi": "\(birthday)",
            "kanGrubu": bloodType,
            "adres": address,
            "parola": password
        ]
        UserDefaults.standard.set(userData, forKey: "kullaniciBilgileri")
        print("Veriler kaydedildi: \(userData)")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
