import Foundation

enum ProductError: Error {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case invalidResponse
}

class ProductService {
    static let shared = ProductService()
    
    func getProducts() async throws -> [Product] {
        guard let url = URL(string: Configuration.baseURL + Configuration.Endpoints.getProducts) else {
            throw ProductError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw ProductError.invalidResponse
        }
        
        do {
            return try JSONDecoder().decode([Product].self, from: data)
        } catch {
            throw ProductError.decodingError(error)
        }
    }
    
    func addProduct(name: String, type: String, price: Double, tax: Double, imageData: Data?) async throws -> ProductResponse {
        guard let url = URL(string: Configuration.baseURL + Configuration.Endpoints.addProduct) else {
            throw ProductError.invalidURL
        }
        
        let boundary = UUID().uuidString
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Add text fields
        let fields = [
            "product_name": name,
            "product_type": type,
            "price": String(price),
            "tax": String(tax)
        ]
        
        for (key, value) in fields {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.append("\(value)\r\n")
        }
        
        // Add image if available
        if let imageData = imageData {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"files[]\"; filename=\"image.jpg\"\r\n")
            body.append("Content-Type: image/jpeg\r\n\r\n")
            body.append(imageData)
            body.append("\r\n")
        }
        
        body.append("--\(boundary)--\r\n")
        request.httpBody = body
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw ProductError.invalidResponse
        }
        
        do {
            return try JSONDecoder().decode(ProductResponse.self, from: data)
        } catch {
            throw ProductError.decodingError(error)
        }
    }
}

private extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
