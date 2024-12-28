import Foundation
import UIKit

@MainActor
class AddProductViewModel: ObservableObject {
    @Published var productName = ""
    @Published var productType = ""
    @Published var price = ""
    @Published var tax = ""
    @Published var selectedImage: UIImage?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    
    let productTypes = ["Product", "Service"]
    
    func validateInputs() -> Bool {
        guard !productName.isEmpty else {
            errorMessage = "Product name is required"
            return false
        }
        
        guard !productType.isEmpty else {
            errorMessage = "Product type is required"
            return false
        }
        
        guard let priceValue = Double(price), priceValue > 0 else {
            errorMessage = "Please enter a valid price"
            return false
        }
        
        guard let taxValue = Double(tax), taxValue >= 0 && taxValue <= 100 else {
            errorMessage = "Please enter a valid tax rate (0-100)"
            return false
        }
        
        return true
    }
    
    func addProduct() async {
        guard validateInputs() else { return }
        
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        do {
            let imageData = selectedImage?.jpegData(compressionQuality: 0.8)
            let response = try await ProductService.shared.addProduct(
                name: productName,
                type: productType,
                price: Double(price) ?? 0,
                tax: Double(tax) ?? 0,
                imageData: imageData
            )
            
            successMessage = response.message
            resetForm()
        } catch {
            errorMessage = "Failed to add product: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    private func resetForm() {
        productName = ""
        productType = ""
        price = ""
        tax = ""
        selectedImage = nil
    }
}
