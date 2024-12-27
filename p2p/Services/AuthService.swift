import Foundation

enum AuthError: Error {
    case invalidCredentials
    case networkError
    case invalidResponse
    case serverError(String)
}

class AuthService {
    static let shared = AuthService()
    // Change localhost to your computer's IP address for device testing
    private let baseURL = "http://127.0.0.1:3000/api/auth"
    
    private var token: String? {
        get { UserDefaults.standard.string(forKey: "authToken") }
        set { UserDefaults.standard.set(newValue, forKey: "authToken") }
    }
    
    func signUp(email: String, password: String) async throws {
        let url = URL(string: "\(baseURL)/register")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["email": email, "password": password]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.invalidResponse
        }
        
        if httpResponse.statusCode == 201 {
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            if let token = json?["token"] as? String {
                self.token = token
            }
        } else {
            let error = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            throw AuthError.serverError(error?["error"] as? String ?? "Unknown error")
        }
    }
    
    func signIn(email: String, password: String) async throws {
        print("Attempting to sign in with email: \(email)")
        let url = URL(string: "\(baseURL)/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["email": email, "password": password]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        print("Sending request to: \(url.absoluteString)")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            print("Received response: \(response)")
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response type")
                throw AuthError.invalidResponse
            }
            
            print("Status code: \(httpResponse.statusCode)")
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("Response data: \(responseString)")
            }
            
            if httpResponse.statusCode == 200 {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                if let token = json?["token"] as? String {
                    self.token = token
                    print("Successfully got token")
                } else {
                    print("No token in response")
                    throw AuthError.invalidResponse
                }
            } else {
                print("Error status code: \(httpResponse.statusCode)")
                throw AuthError.invalidCredentials
            }
        } catch {
            print("Network error: \(error.localizedDescription)")
            throw error
        }
    }
    
    func signOut() {
        token = nil
    }
    
    var isAuthenticated: Bool {
        return token != nil
    }
}
