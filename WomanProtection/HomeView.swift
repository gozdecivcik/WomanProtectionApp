import SwiftUI
import AVFoundation
import CoreLocation
import MessageUI
import FirebaseAuth
import FirebaseFirestore

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var locationManager = LocationManager()

    @State private var isRecording = false
    @State private var audioRecorder: AVAudioRecorder?
    @State private var showEmergencyContacts = false
    @State private var showEmergencyCenters = false
    @State private var showAIChatView = false
    @State private var showFeedbackView = false
    @State private var showProfileView = false
    @State private var isFakeCallActive = false
    @State private var player: AVAudioPlayer?
    @State private var emergencyContacts: [EmergencyContact] = []
    @State private var showLogoutConfirmation = false
    @State private var isLoggingOut = false


    var body: some View {
        NavigationView {
            VStack {
                Spacer()

                Button(action: {
                    handleEmergencyCall()
                }) {
                    Image(systemName: isRecording ? "mic.circle.fill" : "phone.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .padding()
                        .foregroundColor(isRecording ? .red : .blue)
                }

                Text(isRecording ? "Ses Kaydediliyor..." : "Acil Durum Çağrısı")
                    .font(.headline)
                    .foregroundColor(isRecording ? .red : .blue)

                Spacer()

                HStack(spacing: 20) {
                    featureButton(image: "person.crop.circle", title: "Kişiler") {
                        showEmergencyContacts = true
                    }.sheet(isPresented: $showEmergencyContacts) {
                        EmergencyContactsView().environmentObject(appState)
                    }

                    featureButton(image: "mappin.and.ellipse", title: "Merkezler") {
                        showEmergencyCenters = true
                    }.sheet(isPresented: $showEmergencyCenters) {
                        MapView()
                            .presentationDetents([.large])
                                    .presentationDragIndicator(.visible)
                    }

                    featureButton(image: "phone.fill.arrow.up.right", title: "Yalancı Arama") {
                        startFakeCall()
                    }

                    featureButton(image: "message.fill", title: "AI ile Sohbet") {
                        showAIChatView = true
                    }.sheet(isPresented: $showAIChatView) {
                        AIChatView().environmentObject(appState)
                    }

                    featureButton(image: "square.and.pencil", title: "Geri Bildirim") {
                        showFeedbackView = true
                    }.sheet(isPresented: $showFeedbackView) {
                        FeedbackView().environmentObject(appState)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)

                if isFakeCallActive {
                    Button("Yalancı Aramayı Durdur") {
                        stopFakeCall()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGray6))
            .edgesIgnoringSafeArea(.all)
            .navigationBarItems(trailing: settingsButton)
            .onAppear(perform: fetchEmergencyContacts)
            
            .alert(isPresented: $showLogoutConfirmation) {
                Alert(
                    title: Text("Çıkış Yap"),
                    message: Text("Oturumunuzu kapatmak istediğinizden emin misiniz?"),
                    primaryButton: .destructive(Text("Evet")) {
                        performLogout()
                    },
                    secondaryButton: .cancel(Text("Hayır"))
                )
            }

        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    var settingsButton: some View {
        Menu {
            Button(action: { showProfileView = true }) {
                Label("Profil", systemImage: "person.crop.circle")
            }
            Button(action: { shareAudioFile() }) {
                Label("Kaydı Paylaş", systemImage: "square.and.arrow.up")
            }
            Button(role: .destructive) {
                showLogoutConfirmation = true
            } label: {
                Label("Çıkış", systemImage: "arrow.backward.circle")
            }

        } label: {
            Image(systemName: "gearshape.fill")
                .font(.title3)
                .foregroundColor(.primary)
        }
        .sheet(isPresented: $showProfileView) {
            ProfileView().environmentObject(appState)
        }
    }

    func logout() {
        appState.currentScreen = .login
        print("Kullanıcı çıkış yaptı.")
    }

    func handleEmergencyCall() {
        startRecording()
        callEmergencyNumber()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showEmergencySMS()
        }
    }

    func callEmergencyNumber() {
        if let url = URL(string: "tel://112"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }

    func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()

        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)

            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]

            let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let audioFilePath = documentPath.appendingPathComponent("Kanıtlar/EmergencyRecording.m4a")

            try FileManager.default.createDirectory(at: documentPath.appendingPathComponent("Kanıtlar"), withIntermediateDirectories: true)

            audioRecorder = try AVAudioRecorder(url: audioFilePath, settings: settings)
            audioRecorder?.record()
            isRecording = true

            saveRecordingToFirebase(audioFilePath: audioFilePath)
        } catch {
            print("Kayıt başlatılamadı: \(error.localizedDescription)")
        }
    }

    func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
        isRecording = false
    }

    func saveRecordingToFirebase(audioFilePath: URL) {
        guard let audioData = try? Data(contentsOf: audioFilePath) else { return }
        let base64Audio = audioData.base64EncodedString()

        guard let userID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()

        let audioDoc: [String: Any] = [
            "base64Audio": base64Audio,
            "timestamp": Timestamp(date: Date())
        ]

        db.collection("users").document(userID).collection("recordings").addDocument(data: audioDoc) { error in
            if let error = error {
                print("Ses yükleme hatası: \(error.localizedDescription)")
            } else {
                print("✅ Ses kaydı yüklendi")
            }
        }
    }

    func startFakeCall() {
        guard let soundURL = Bundle.main.url(forResource: "ringtonemp3", withExtension: "wav") else { return }
        do {
            player = try AVAudioPlayer(contentsOf: soundURL)
            player?.numberOfLoops = -1
            player?.play()
            isFakeCallActive = true
        } catch {
            print("Fake çağrı hatası: \(error.localizedDescription)")
        }
    }

    func stopFakeCall() {
        player?.stop()
        isFakeCallActive = false
    }

    func shareAudioFile() {
        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFilePath = documentPath.appendingPathComponent("Kanıtlar/EmergencyRecording.m4a")

        let activityVC = UIActivityViewController(activityItems: [audioFilePath], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true)
    }

    func featureButton(image: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack {
                Image(systemName: image)
                    .font(.system(size: 24))
                    .foregroundColor(.primary)
                Text(title)
                    .font(.footnote)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
        }
    }

    func fetchEmergencyContacts() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()

        db.collection("users").document(userID).collection("emergencyContacts").getDocuments { snapshot, error in
            if let error = error {
                print("Kişiler alınamadı: \(error.localizedDescription)")
                return
            }

            self.emergencyContacts = snapshot?.documents.compactMap { doc in
                let data = doc.data()
                guard let name = data["name"] as? String,
                      let phoneNumber = data["phoneNumber"] as? String else { return nil }
                return EmergencyContact(name: name, phoneNumber: phoneNumber)
            } ?? []
        }
    }

    func showEmergencySMS() {
        guard MFMessageComposeViewController.canSendText() else {
            print("SMS gönderilemiyor.")
            return
        }

        let phoneNumbers = emergencyContacts.map { $0.phoneNumber }
        let lat = locationManager.userLocation?.latitude ?? 0.0
        let lon = locationManager.userLocation?.longitude ?? 0.0
        let mapsLink = "https://maps.google.com/?q=\(lat),\(lon)"

        let messageBody = """
        🚨 Acil durumdayım! Yardım edin!
        Konumum: \(mapsLink)
        """

        let messageVC = MFMessageComposeViewController()
        messageVC.body = messageBody
        messageVC.recipients = phoneNumbers
        messageVC.messageComposeDelegate = UIApplication.shared.windows.first?.rootViewController as? MFMessageComposeViewControllerDelegate

        UIApplication.shared.windows.first?.rootViewController?.present(messageVC, animated: true)
    }
    
    func performLogout() {
        isLoggingOut = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            try? Auth.auth().signOut()
            isLoggingOut = false
            appState.currentScreen = .login
            print("Kullanıcı çıkış yaptı.")
        }
    }

}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView().environmentObject(AppState())
    }
}
