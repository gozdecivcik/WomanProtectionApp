//
//  MapViewRepresentable.swift
//  WomanProtection
//
//  Created by Zeynep on 28.05.2025.
//

import SwiftUI
import MapKit

struct MapViewRepresentable: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    var annotations: [MKPointAnnotation]
    @Binding var forceCenter: Bool
    var userLocation: CLLocationCoordinate2D?

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.showsUserLocation = true
        mapView.delegate = context.coordinator
        mapView.setRegion(region, animated: false)

        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Haritayı manuel olarak merkezle
        uiView.setRegion(region, animated: true)

        if forceCenter, let userLocation = userLocation {
            let newRegion = MKCoordinateRegion(
                center: userLocation,
                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            )
            uiView.setRegion(newRegion, animated: true)
            DispatchQueue.main.async {
                forceCenter = false
            }
        }

        uiView.removeAnnotations(uiView.annotations)
        uiView.addAnnotations(annotations)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(forceCenter: $forceCenter)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        @Binding var forceCenter: Bool

        init(forceCenter: Binding<Bool>) {
            _forceCenter = forceCenter
        }

        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            // Kullanıcı haritayı oynattıysa otomatik merkezlemeyi iptal et
            forceCenter = false
        }
    }
}





