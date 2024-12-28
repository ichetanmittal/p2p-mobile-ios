import SwiftUI

struct ProductCardView: View {
    let product: Product
    let onFavorite: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Product Image
            AsyncImage(url: URL(string: product.image ?? "")) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(height: 200)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .clipped()
                case .failure:
                    Image(systemName: "photo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 200)
                        .foregroundColor(.gray)
                @unknown default:
                    EmptyView()
                }
            }
            .frame(maxWidth: .infinity)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            
            // Product Details
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(product.productName)
                        .font(.headline)
                    Spacer()
                    Button(action: onFavorite) {
                        Image(systemName: product.isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(product.isFavorite ? .red : .gray)
                    }
                }
                
                Text(product.productType)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text("₹\(String(format: "%.2f", product.price))")
                        .font(.title3)
                        .bold()
                    
                    Spacer()
                    
                    Text("Tax: \(String(format: "%.1f", product.tax))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}
