//
//  EmergencyCentersView.swift
//  WomanProtection
//
//  Created by Gözde Civcik on 18.12.2024.
//

import SwiftUI
import MapKit

struct EmergencyCentersView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    var body: some View {
        Map(coordinateRegion: $region, annotationItems: emergencyCenters) { center in
            MapMarker(coordinate: center.coordinate, tint: .red)
        }
        .edgesIgnoringSafeArea(.all)
        .navigationTitle("Acil Durum Merkezleri")
    }
}

struct EmergencyCenter: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}

let emergencyCenters = [
    EmergencyCenter(name: "Hastane A", coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)),
    EmergencyCenter(name: "Polis Merkezi B", coordinate: CLLocationCoordinate2D(latitude: 37.7849, longitude: -122.4094))
]
