//
//  SplashView.swift
//  WomanProtection
//
//  Created by Zeynep on 29.05.2025.
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        VStack {
            Spacer()
            ProgressView("Yükleniyor...")
                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

