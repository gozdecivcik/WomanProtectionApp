import SwiftUI

struct AIChatView: View {
    @State private var userInput: String = ""
    @State private var messages: [(String, Bool)] = [("Merhaba! Size nasıl yardımcı olabilirim?", false)]
    @State private var errorMessage: String?
    @State private var predefinedMessages: [String] = [
        "Biri beni takip ediyor, ne yapmalıyım?",
        "Trafikte biri bana küfür ediyor ve saldırıyor, ne yapmalıyım?",
        "Evde yalnızım ve kapı çalıyor, korkuyorum ne yapmalıyım?",
        "Birinden tehdit mesajı aldım, ne yapmalıyım?"
    ]

    let aiService = AIService()

    var body: some View {
        VStack {
            ScrollViewReader { scrollProxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(messages.indices, id: \.self) { index in
                            HStack {
                                if messages[index].1 {
                                    Spacer()
                                    ChatBubble(text: messages[index].0, isUser: true)
                                } else {
                                    ChatBubble(text: messages[index].0, isUser: false)
                                    Spacer()
                                }
                            }
                        }

                        if let errorMessage = errorMessage {
                            Text("⚠️ \(errorMessage)")
                                .foregroundColor(.red)
                                .padding(.horizontal)
                        }

                        // 🔘 Hazır Mesajlar
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Hazır Yardım Mesajları:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            ForEach(predefinedMessages, id: \.self) { message in
                                Button(action: {
                                    userInput = message
                                    sendMessage()
                                }) {
                                    Text(message)
                                        .padding(10)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color(.secondarySystemBackground))
                                        .foregroundColor(.primary)
                                        .cornerRadius(10)
                                }
                            }
                        }
                        .padding(.top)
                    }
                    .padding()
                    .onChange(of: messages.count) { _ in
                        withAnimation {
                            scrollProxy.scrollTo(messages.count - 1, anchor: .bottom)
                        }
                    }
                }
            }

            HStack(spacing: 10) {
                TextField("Mesajınızı yazın...", text: $userInput)
                    .padding(12)
                    .background(Color(.secondarySystemBackground))
                    .foregroundColor(.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.blue)
                }
                .disabled(userInput.isEmpty)
            }
            .padding()
        }
        .navigationTitle("🧠 AI Asistan")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemBackground).ignoresSafeArea())
    }

    func sendMessage() {
        let prompt = userInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !prompt.isEmpty else { return }

        messages.append((prompt, true))
        userInput = ""
        errorMessage = nil

        aiService.getAIResponse(for: prompt) { response in
            if response.lowercased().contains("bir hata oluştu") {
                self.errorMessage = "AI'dan yanıt alınamadı. Bağlantınızı kontrol edin."
            } else {
                self.messages.append((response, false))
            }
        }
    }
}

struct ChatBubble: View {
    let text: String
    let isUser: Bool

    var body: some View {
        Text(text)
            .padding(12)
            .background(isUser ? Color.blue : Color(.tertiarySystemFill))
            .foregroundColor(isUser ? .white : .primary)
            .cornerRadius(16)
            .frame(maxWidth: 300, alignment: isUser ? .trailing : .leading)
    }
}
