//
//  PhotoViewModel.swift
//  ExpensesTracker
//
//  Created by Jorge Ramos on 01/08/25.
//
import Foundation
import UIKit
import Combine

class PhotoViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var ocrText: String?
    @Published var aiParseData: AiParseData?
    @Published var errorMessage: String?

    private let ocrService: OCRService
    private let openAIService: OpenAIService

    init(ocrService: OCRService, openAIService: OpenAIService) {
        self.ocrService = ocrService
        self.openAIService = openAIService
    }

    func processImage(_ image: UIImage) {
        isLoading = true
        errorMessage = nil
        ocrService.recognizeText(from: image) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let ocrResponse):
                    if let text = ocrResponse.parsedResults.first?.parsedText {
                        self?.ocrText = text
                        self?.callOpenAI(with: text)
                    } else {
                        self?.isLoading = false
                        self?.errorMessage = "OCR Error: No text found."
                    }
                case .failure(let error):
                    self?.isLoading = false
                    self?.errorMessage = "OCR Error: \(error.localizedDescription)"
                }
            }
        }
    }
    private func callOpenAI(with text: String) {
        openAIService.extractExpense(from: text) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let data):
                    self?.aiParseData = data
                case .failure(let error):
                    self?.errorMessage = "OpenAI Error: \(error.localizedDescription)"
                }
            }
        }
    }
}
