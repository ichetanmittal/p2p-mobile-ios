import SwiftUI

struct SignUpView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var phone = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showVerification = false
    @State private var userId = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Create Account")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 50)
            
            VStack(spacing: 20) {
                TextField("Name", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.words)
                
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                
                TextField("Phone", text: $phone)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.phonePad)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding(.horizontal)
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }
            
            Button(action: signUp) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Sign Up")
                }
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .cornerRadius(10)
            .padding(.horizontal)
            .disabled(isLoading || email.isEmpty || password.isEmpty || name.isEmpty || phone.isEmpty)
            
            HStack {
                Text("Already have an account?")
                NavigationLink("Sign In") {
                    SignInView()
                }
            }
            
            Spacer()
        }
        .padding()
        .navigationDestination(isPresented: $showVerification) {
            VerificationView(userId: userId)
        }
    }
    
    private func signUp() {
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                let response = try await AuthService.shared.signUp(email: email, password: password, name: name, phone: phone)
                if let id = response["userId"] as? String {
                    userId = id
                    showVerification = true
                }
            } catch AuthError.serverError(let message) {
                errorMessage = message
            } catch {
                errorMessage = "Failed to sign up. Please try again."
            }
            isLoading = false
        }
    }
}

#Preview {
    SignUpView()
}
