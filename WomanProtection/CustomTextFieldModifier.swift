//
//  CustomTextFieldModifier.swift
//  WomanProtection
//
//  Created by Zeynep on 29.05.2025.
//

import SwiftUI

struct CustomTextFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(12)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            .font(.system(size: 16, weight: .regular))
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

extension View {
    func customTextFieldStyle() -> some View {
        self.modifier(CustomTextFieldModifier())
    }
}

