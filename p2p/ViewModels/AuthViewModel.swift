import SwiftUI

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    
    static let shared = AuthViewModel()
    
    private init() {
        isAuthenticated = AuthService.shared.isAuthenticated
    }
    
    func signIn(identifier: String, password: String) async throws {
        try await AuthService.shared.signIn(identifier: identifier, password: password)
        await MainActor.run {
            self.isAuthenticated = true
        }
    }
    
    func signOut() {
        AuthService.shared.signOut()
        isAuthenticated = false
    }
}
