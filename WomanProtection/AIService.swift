import Foundation

class AIService {
    let apiKey = "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" // 🔐 Buraya OpenRouter API anahtarını yaz

    func getAIResponse(for prompt: String, completion: @escaping (String) -> Void) {
        guard let url = URL(string: "https://openrouter.ai/api/v1/chat/completions") else {
            completion("Geçersiz URL.")
            return
        }

        let headers = [
            "Authorization": "Bearer \(apiKey)",
            "Content-Type": "application/json"
        ]

        let body: [String: Any] = [
            "model": "mistralai/mistral-7b-instruct", // İstersen başka model kullanabilirsin
            "messages": [
                ["role": "user", "content": prompt]
            ]
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            completion("❌ JSON hatası: \(error.localizedDescription)")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion("❌ Ağ hatası: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                completion("❌ Sunucudan boş veri geldi.")
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let message = choices.first?["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    DispatchQueue.main.async {
                        completion(content.trimmingCharacters(in: .whitespacesAndNewlines))
                    }
                } else {
                    let rawText = String(data: data, encoding: .utf8) ?? "Veri okunamadı"
                    completion("❌ Yanıt işlenemedi:\n\(rawText)")
                }
            } catch {
                completion("❌ Parse hatası: \(error.localizedDescription)")
            }
        }.resume()
    }
}
