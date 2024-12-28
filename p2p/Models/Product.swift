import Foundation

struct Product: Identifiable, Codable {
    let id: Int?
    let productName: String
    let productType: String
    let price: Double
    let tax: Double
    let image: String?
    var isFavorite: Bool = false
    
    mutating func toggleFavorite() {
        isFavorite.toggle()
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "product_id"
        case productName = "product_name"
        case productType = "product_type"
        case price
        case tax
        case image
    }
}

struct ProductResponse: Codable {
    let message: String
    let productDetails: Product
    let productId: Int
    let success: Bool
    
    enum CodingKeys: String, CodingKey {
        case message
        case productDetails = "product_details"
        case productId = "product_id"
        case success
    }
}
