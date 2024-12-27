import SwiftUI

struct VerificationView: View {
    let userId: String
    @State private var verificationCode = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    @StateObject private var authViewModel = AuthViewModel.shared
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Verify Email")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Please enter the verification code sent to your email")
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
            
            TextField("Verification Code", text: $verificationCode)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
                .frame(maxWidth: 200)
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
            
            Button(action: verifyCode) {
                if isLoading {
                    ProgressView()
                } else {
                    Text("Verify")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .disabled(isLoading || verificationCode.isEmpty)
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .navigationDestination(isPresented: $authViewModel.isAuthenticated) {
            MainView()
        }
    }
    
    private func verifyCode() {
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                try await AuthService.shared.verifyEmail(userId: userId, code: verificationCode)
                authViewModel.isAuthenticated = true
            } catch AuthError.serverError(let message) {
                errorMessage = message
            } catch {
                errorMessage = "Failed to verify code. Please try again."
            }
            isLoading = false
        }
    }
}
