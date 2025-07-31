//
//  OpenAiResponse.swift
//  ExpensesTracker
//
//  Created by Jorge Ramos on 31/07/25.
//
struct OpenAIResponse: Codable {
    struct Choice: Codable {
        struct Message: Codable {
            let content: String
        }
        let message: Message
    }
    let choices: [Choice]
}
