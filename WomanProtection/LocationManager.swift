import SwiftUI
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()

    @Published var userLocation: CLLocationCoordinate2D?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        // 🔥 Hem "Kullanırken" hem "Her Zaman" izni iste
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()

        // 🔥 Uygulama açılınca ANLIK konum iste
        locationManager.requestLocation()

        // 🔥 Devamlı konum güncellemesi başlat
        locationManager.startUpdatingLocation()
    }

    // 🔥 Lokasyon güncellemelerini alıyoruz
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.userLocation = location.coordinate
            print("📍 Konum güncellendi: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        }
    }

    // 🔥 Lokasyon alınamadıysa hatayı yakala
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("🚨 Lokasyon alınamadı: \(error.localizedDescription)")
    }
}
