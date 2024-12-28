import Foundation

enum Configuration {
    static let baseURL = "https://app.getswipe.in/api/public"
    
    enum Endpoints {
        static let getProducts = "/get"
        static let addProduct = "/add"
    }
    
    enum UserDefaultsKeys {
        static let favoritePrefix = "favorite_"
    }
}
