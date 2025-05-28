import SwiftUI

struct AIChatView: View {
    @State private var userInput: String = ""
    @State private var messages: [String] = ["Merhaba! Nasıl yardımcı olabilirim?"]
    @State private var errorMessage: String?

    let aiService = AIService()

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

                    if let errorMessage = errorMessage {
                        Text("⚠️ \(errorMessage)")
                            .foregroundColor(.red)
                            .padding(.top)
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

        let prompt = userInput
        messages.append("Siz: \(prompt)")
        userInput = ""
        errorMessage = nil

        aiService.getAIResponse(for: prompt) { response in
            if response.lowercased().contains("❌") {
                self.errorMessage = response
            } else {
                self.messages.append("AI: \(response)")
            }
        }
    }
}
