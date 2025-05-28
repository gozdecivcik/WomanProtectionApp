//
//  LocationView.swift
//  WomanProtection
//
//  Created by Gözde Civcik on 22.12.2024.
//


import SwiftUI

struct LocationView: View {
    @StateObject private var locationManager = LocationManager()

    var body: some View {
        VStack {
            if let location = locationManager.userLocation {
                Text("Enlem: \(location.latitude)")
                Text("Boylam: \(location.longitude)")
            } else {
                Text("Konum alınıyor...")
            }
        }
        .padding()
    }
}
