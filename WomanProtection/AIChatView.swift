//
//  AIChatView.swift
//  WomanProtection
//
//  Created by Gözde Civcik on 22.12.2024.
//


import SwiftUI

struct AIChatView: View {
    @State private var userInput: String = ""
    @State private var messages: [String] = ["Merhaba! Nasıl yardımcı olabilirim?"]
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(messages, id: \.self) { message in
                        Text(message)
                            .padding()
                            .background(Color(.systemGray5))
                            .cornerRadius(10)
                            .padding(.vertical, 2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .padding()
            
            HStack {
                TextField("Sorunuzu yazın...", text: $userInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button(action: {
                    sendMessage()
                }) {
                    Image(systemName: "paperplane.fill")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
            }
            .padding()
        }
        .navigationTitle("AI ile Sohbet")
    }
    
    func sendMessage() {
        guard !userInput.isEmpty else { return }
        messages.append("Siz: \(userInput)")
        // Simüle edilmiş bir AI cevabı
        messages.append("AI: \(userInput) hakkında daha fazla bilgi alıyorum.")
        userInput = ""
    }
}
