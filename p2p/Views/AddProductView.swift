import SwiftUI
import PhotosUI

struct AddProductView: View {
    @StateObject private var viewModel = AddProductViewModel()
    @Binding var isPresented: Bool
    @State private var selectedItem: PhotosPickerItem?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Product Details")) {
                    TextField("Product Name", text: $viewModel.productName)
                    
                    Picker("Product Type", selection: $viewModel.productType) {
                        Text("Select Type").tag("")
                        ForEach(viewModel.productTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    
                    TextField("Price", text: $viewModel.price)
                        .keyboardType(.decimalPad)
                    
                    TextField("Tax Rate (%)", text: $viewModel.tax)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Product Image")) {
                    if let image = viewModel.selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                    }
                    
                    PhotosPicker(
                        selection: $selectedItem,
                        matching: .images
                    ) {
                        Label(viewModel.selectedImage == nil ? "Select Image" : "Change Image",
                              systemImage: "photo")
                    }
                    .onChange(of: selectedItem) { newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                               let image = UIImage(data: data) {
                                await MainActor.run {
                                    viewModel.selectedImage = image
                                }
                            }
                        }
                    }
                }
                
                if viewModel.isLoading {
                    Section {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    }
                }
                
                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
                
                if let successMessage = viewModel.successMessage {
                    Section {
                        Text(successMessage)
                            .foregroundColor(.green)
                    }
                }
            }
            .navigationTitle("Add Product")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        Task {
                            await viewModel.addProduct()
                        }
                    }
                    .disabled(viewModel.isLoading)
                }
            }
        }
    }
}
