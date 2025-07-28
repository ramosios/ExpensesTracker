//
//  OCRResponse.swift
//  ExpensesTracker
//
//  Created by Jorge Ramos on 28/07/25.
//
import Foundation

// MARK: - OCRResponse
struct OCRResponse: Codable {
    let parsedResults: [ParsedResult]
    let ocrExitCode: Int
    let isErroredOnProcessing: Bool
    let processingTimeInMilliseconds: String
    let searchablePDFURL: String?

    enum CodingKeys: String, CodingKey {
        case parsedResults = "ParsedResults"
        case ocrExitCode = "OCRExitCode"
        case isErroredOnProcessing = "IsErroredOnProcessing"
        case processingTimeInMilliseconds = "ProcessingTimeInMilliseconds"
        case searchablePDFURL = "SearchablePDFURL"
    }
}

// MARK: - ParsedResult
struct ParsedResult: Codable {
    let textOverlay: TextOverlay?
    let fileParseExitCode: Int
    let parsedText: String
    let errorMessage: String
    let errorDetails: String

    enum CodingKeys: String, CodingKey {
        case textOverlay = "TextOverlay"
        case fileParseExitCode = "FileParseExitCode"
        case parsedText = "ParsedText"
        case errorMessage = "ErrorMessage"
        case errorDetails = "ErrorDetails"
    }
}

// MARK: - TextOverlay
struct TextOverlay: Codable {
    let lines: [Line]
    let hasOverlay: Bool
    let message: String

    enum CodingKeys: String, CodingKey {
        case lines = "Lines"
        case hasOverlay = "HasOverlay"
        case message = "Message"
    }
}

// MARK: - Line
struct Line: Codable {
    let lineText: String
    let words: [Word]
    let maxHeight: Double
    let minTop: Double

    enum CodingKeys: String, CodingKey {
        case lineText = "LineText"
        case words = "Words"
        case maxHeight = "MaxHeight"
        case minTop = "MinTop"
    }
}

// MARK: - Word
struct Word: Codable {
    let wordText: String
    let left: Double
    let top: Double
    let height: Double
    let width: Double

    enum CodingKeys: String, CodingKey {
        case wordText = "WordText"
        case left = "Left"
        case top = "Top"
        case height = "Height"
        case width = "Width"
    }
}
