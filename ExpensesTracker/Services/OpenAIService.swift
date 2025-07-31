//
//  OpenAIService.swift
//  ExpensesTracker
//
//  Created by Jorge Ramos on 31/07/25.
//
import Foundation

class OpenAIService {
    private let apiKey: String

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    func extractExpense(from ocrText: String, completion: @escaping (Result<AiParseData, Error>) -> Void) {
        let prompt = """
        Extract the amount, date, category, and description from the following receipt text and return as JSON:
        \(ocrText)
        """

        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "user", "content": prompt]
            ],
            "max_tokens": 150
        ]

        guard let url = URL(string: "https://api.openai.com/v1/chat/completions"),
              let httpBody = try? JSONSerialization.data(withJSONObject: requestBody) else {
            completion(.failure(NSError(domain: "InvalidRequest", code: 0)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody

        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data,
                  let response = try? JSONDecoder().decode(OpenAIResponse.self, from: data),
                  let content = response.choices.first?.message.content,
                  let expenseData = content.data(using: .utf8),
                  let aiParseData = try? JSONDecoder().decode(AiParseData.self, from: expenseData) else {
                completion(.failure(NSError(domain: "ParsingError", code: 0)))
                return
            }
            completion(.success(aiParseData))
        }
        task.resume()
    }
}
