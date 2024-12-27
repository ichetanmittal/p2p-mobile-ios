import SwiftUI

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    
    static let shared = AuthViewModel()
    
    private init() {
        isAuthenticated = AuthService.shared.isAuthenticated
    }
    
    func signIn(email: String, password: String) async throws {
        try await AuthService.shared.signIn(email: email, password: password)
        await MainActor.run {
            self.isAuthenticated = true
        }
    }
    
    func signOut() {
        AuthService.shared.signOut()
        isAuthenticated = false
    }
}
