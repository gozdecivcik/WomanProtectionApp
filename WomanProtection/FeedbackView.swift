import SwiftUI
import PhotosUI
import FirebaseFirestore
import FirebaseAuth

struct FeedbackView: View {
    @State private var feedbackText: String = ""
    @State private var locationText: String = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var shareLocation: Bool = false

    var body: some View {
        VStack {
            Form {
                Section(header: Text("Geri Bildirim")) {
                    TextEditor(text: $feedbackText)
                        .frame(height: 150)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                }
                
                Section(header: Text("Konum Bilgisi")) {
                    if shareLocation {
                        Text("Konum paylaşımı açık.")
                            .foregroundColor(.gray)
                    } else {
                        TextField("Konumunuzu manuel olarak yazın", text: $locationText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    Toggle(isOn: $shareLocation) {
                        Text("Konumumu Otomatik Paylaş")
                    }
                }
                
                Section(header: Text("Fotoğraf Ekle")) {
                    if let selectedImage = selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .cornerRadius(10)
                            .padding(.vertical)
                    }
                    
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        Text("Fotoğraf Seç")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
            
            Button(action: {
                submitFeedback()
            }) {
                Text("Gönder")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(feedbackText.isEmpty && locationText.isEmpty && selectedImage == nil)
            .padding()
        }
        .navigationTitle("Geri Bildirim")
        .onChange(of: selectedPhoto) { newValue in
            loadImage(from: newValue)
        }
    }
    
    func submitFeedback() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Kullanıcı oturumu yok.")
            return
        }

        var feedbackData: [String: Any] = [
            "feedbackText": feedbackText,
            "timestamp": Timestamp(date: Date())
        ]

        if shareLocation {
            feedbackData["location"] = "Otomatik konum paylaşımı aktif"
        } else if !locationText.isEmpty {
            feedbackData["location"] = locationText
        }

        if let selectedImage = selectedImage,
           let imageData = selectedImage.jpegData(compressionQuality: 0.7) {
            let base64String = imageData.base64EncodedString()
            feedbackData["imageBase64"] = base64String
        }

        let db = Firestore.firestore()
        db.collection("users").document(userID).collection("feedbacks").addDocument(data: feedbackData) { error in
            if let error = error {
                print("Geri bildirim gönderilemedi: \(error.localizedDescription)")
            } else {
                print("✅ Geri bildirim başarıyla gönderildi.")
                feedbackText = ""
                locationText = ""
                selectedImage = nil
                selectedPhoto = nil
                shareLocation = false
            }
        }
    }

    func loadImage(from item: PhotosPickerItem?) {
        guard let item = item else { return }
        
        item.loadTransferable(type: Data.self) { result in
            switch result {
            case .success(let data):
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        selectedImage = image
                    }
                }
            case .failure(let error):
                print("Fotoğraf yüklenirken hata oluştu: \(error.localizedDescription)")
            }
        }
    }
}
