//
//  OpenAIService.swift
//  ExpensesTracker
//
//  Created by Jorge Ramos on 31/07/25.
//
import Foundation

enum OpenAIServiceError: Error {
    case invalidRequest
    case network(Error)
    case invalidResponse
    case decoding(Error)
    case openAIError(String)
}

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
            completion(.failure(OpenAIServiceError.invalidRequest))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(OpenAIServiceError.network(error)))
                return
            }
            guard let data = data else {
                completion(.failure(OpenAIServiceError.invalidResponse))
                return
            }
            do {
                let response = try JSONDecoder().decode(OpenAIResponse.self, from: data)
                guard let content = response.choices.first?.message.content,
                      let expenseData = content.data(using: .utf8) else {
                    completion(.failure(OpenAIServiceError.invalidResponse))
                    return
                }
                let aiParseData = try JSONDecoder().decode(AiParseData.self, from: expenseData)
                completion(.success(aiParseData))
            } catch let decodeError {
                completion(.failure(OpenAIServiceError.decoding(decodeError)))
            }
        }
        task.resume()
    }
}
