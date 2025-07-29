import Foundation
import UIKit

enum OCRServiceError: Error {
    case invalidImageData
    case stringEncodingFailed
    case invalidEndpoint
    case noDataReceived
}

class OCRService {
    private let apiKey: String

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    func recognizeText(from image: UIImage, completion: @escaping (Result<OCRResponse, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(OCRServiceError.invalidImageData))
            return
        }

        guard var urlComponents = URLComponents(string: "https://api.ocr.space/parse/image") else {
            completion(.failure(OCRServiceError.invalidEndpoint))
            return
        }
        urlComponents.queryItems = [URLQueryItem(name: "apikey", value: apiKey)]
        guard let endpoint = urlComponents.url else {
            completion(.failure(OCRServiceError.invalidEndpoint))
            return
        }

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        func appendString(_ string: String) throws {
            guard let data = string.data(using: .utf8) else {
                throw OCRServiceError.stringEncodingFailed
            }
            body.append(data)
        }

        do {
            try appendString("--\(boundary)\r\n")
            try appendString("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n")
            try appendString("Content-Type: image/jpeg\r\n\r\n")
            body.append(imageData)
            try appendString("\r\n")
            try appendString("--\(boundary)\r\n")
            try appendString("Content-Disposition: form-data; name=\"language\"\r\n\r\n")
            try appendString("eng\r\n")
            try appendString("--\(boundary)--\r\n")
        } catch {
            completion(.failure(error))
            return
        }

        request.httpBody = body

        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(OCRServiceError.noDataReceived))
                return
            }
            do {
                let ocrResponse = try JSONDecoder().decode(OCRResponse.self, from: data)
                completion(.success(ocrResponse))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
