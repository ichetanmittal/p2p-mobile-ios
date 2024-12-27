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
        get { 
            let token = UserDefaults.standard.string(forKey: "authToken")
            print("Retrieved token from UserDefaults: \(token ?? "nil")")
            return token
        }
        set { 
            print("Saving token to UserDefaults: \(newValue ?? "nil")")
            UserDefaults.standard.set(newValue, forKey: "authToken") 
        }
    }
    
    func signUp(email: String, password: String, name: String, phone: String) async throws -> [String: Any] {
        print("📱 Attempting signup - Email: \(email), Name: \(name), Phone: \(phone)")
        let url = URL(string: "\(baseURL)/register")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["email": email, "password": password, "name": name, "phone": phone]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ Invalid response type")
            throw AuthError.invalidResponse
        }
        
        print("🔄 Server response status: \(httpResponse.statusCode)")
        
        if httpResponse.statusCode == 201 {
            if let responseString = String(data: data, encoding: .utf8) {
                print("✅ Signup successful. Response: \(responseString)")
            }
            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                throw AuthError.invalidResponse
            }
            if let token = json["token"] as? String {
                self.token = token
                print("🎟 Token received and saved")
            }
            return json
        } else {
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = json["error"] as? String {
                print("❌ Server error: \(error)")
                throw AuthError.serverError(error)
            }
            print("❌ Invalid response")
            throw AuthError.invalidResponse
        }
    }
    
    func signIn(identifier: String, password: String) async throws {
        print("📱 Attempting signin - Identifier: \(identifier)")
        let url = URL(string: "\(baseURL)/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["identifier": identifier, "password": password]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ Invalid response type")
            throw AuthError.invalidResponse
        }
        
        print("🔄 Server response status: \(httpResponse.statusCode)")
        
        if httpResponse.statusCode == 200 {
            if let responseString = String(data: data, encoding: .utf8) {
                print("✅ Signin successful. Response: \(responseString)")
            }
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            if let token = json?["token"] as? String {
                self.token = token
                print("🎟 Token received and saved")
            }
        } else {
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = json["error"] as? String {
                print("❌ Server error: \(error)")
                throw AuthError.serverError(error)
            }
            print("❌ Invalid response")
            throw AuthError.invalidResponse
        }
    }
    
    func verifyEmail(userId: String, code: String) async throws {
        print("📱 Attempting to verify email - UserId: \(userId)")
        let url = URL(string: "\(baseURL)/verify")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["userId": userId, "code": code]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ Invalid response type")
            throw AuthError.invalidResponse
        }
        
        print("🔄 Server response status: \(httpResponse.statusCode)")
        
        if httpResponse.statusCode == 200 {
            if let responseString = String(data: data, encoding: .utf8) {
                print("✅ Email verification successful. Response: \(responseString)")
            }
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            if let token = json?["token"] as? String {
                self.token = token
                print("🎟 Token received and saved")
            }
        } else {
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = json["error"] as? String {
                print("❌ Server error: \(error)")
                throw AuthError.serverError(error)
            }
            print("❌ Invalid response")
            throw AuthError.invalidResponse
        }
    }
    
    func signOut() {
        print("🚪 Signing out - Removing token")
        token = nil
    }
    
    var isAuthenticated: Bool {
        return token != nil
    }
}
