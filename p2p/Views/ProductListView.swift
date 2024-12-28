import SwiftUI

struct ProductListView: View {
    @StateObject private var viewModel = ProductListViewModel()
    @State private var showingAddProduct = false
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                } else if let errorMessage = viewModel.errorMessage {
                    VStack {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        Button("Retry") {
                            Task {
                                await viewModel.fetchProducts()
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.filteredProducts) { product in
                                ProductCardView(product: product) {
                                    if let id = product.id {
                                        viewModel.toggleFavorite(for: id)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("Products")
            .searchable(text: $viewModel.searchText, prompt: "Search products")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddProduct = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingAddProduct) {
                AddProductView(isPresented: $showingAddProduct)
            }
        }
        .task {
            await viewModel.fetchProducts()
        }
        .refreshable {
            await viewModel.fetchProducts()
        }
    }
}
