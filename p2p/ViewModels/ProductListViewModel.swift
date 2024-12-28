import Foundation
import Combine

@MainActor
class ProductListViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var filteredProducts: [Product] = []
    @Published var isLoading = false
    @Published var searchText = ""
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupSearchSubscription()
    }
    
    private func setupSearchSubscription() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] searchText in
                self?.filterProducts(searchText: searchText)
            }
            .store(in: &cancellables)
    }
    
    private func filterProducts(searchText: String) {
        if searchText.isEmpty {
            filteredProducts = products.sorted { $0.isFavorite && !$1.isFavorite }
        } else {
            filteredProducts = products
                .filter { $0.productName.lowercased().contains(searchText.lowercased()) }
                .sorted { $0.isFavorite && !$1.isFavorite }
        }
    }
    
    func fetchProducts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            products = try await ProductService.shared.getProducts()
            // Load favorite status for each product
            products = products.map { product in
                var updatedProduct = product
                if let id = product.id {
                    updatedProduct.isFavorite = loadFavoriteStatus(productId: id)
                }
                return updatedProduct
            }
            filterProducts(searchText: searchText)
        } catch {
            errorMessage = "Failed to fetch products: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func toggleFavorite(for productId: Int) {
        if let index = products.firstIndex(where: { $0.id == productId }) {
            products[index].isFavorite.toggle()
            filterProducts(searchText: searchText)
            saveFavoriteStatus(productId: productId, isFavorite: products[index].isFavorite)
        }
    }
    
    private func saveFavoriteStatus(productId: Int, isFavorite: Bool) {
        UserDefaults.standard.set(isFavorite, forKey: "favorite_\(productId)")
    }
    
    private func loadFavoriteStatus(productId: Int) -> Bool {
        UserDefaults.standard.bool(forKey: "favorite_\(productId)")
    }
}
