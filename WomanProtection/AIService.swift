import Foundation

class AIService {
    let apiKey = "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" // 🔐 Buraya OpenRouter API anahtarını yaz
    
    func getAIResponse(for prompt: String, completion: @escaping (String) -> Void) {
        guard let url = URL(string: "https://openrouter.ai/api/v1/chat/completions") else {
            completion("❌ Geçersiz URL.")
            return
        }

        let headers = [
            "Authorization": "Bearer \(apiKey)",
            "Content-Type": "application/json"
        ]

        let body: [String: Any] = [
            "model": "deepseek/deepseek-r1:free", // alternatif: "openai/gpt-3.5-turbo"
            "messages": [
                ["role": "system", "content": "Kısa, net ve güvenli cevaplar ver. Panikleyen birine yardımcı oluyorsun."],
                ["role": "user", "content": prompt]
            ]
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            completion("❌ JSON oluşturulamadı: \(error.localizedDescription)")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion("❌ Ağ hatası: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                completion("❌ Boş veri döndü.")
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
                    let raw = String(data: data, encoding: .utf8) ?? "Yanıt okunamadı."
                    completion("❌ Beklenmeyen yanıt formatı:\n\(raw)")
                }
            } catch {
                completion("❌ Parse hatası: \(error.localizedDescription)")
            }
        }.resume()
    } }
