import SwiftUI

struct SignInView: View {
    @StateObject private var authViewModel = AuthViewModel.shared
    @State private var identifier = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Sign In")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 50)
            
            VStack(spacing: 20) {
                TextField("Email or Phone", text: $identifier)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding(.horizontal)
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }
            
            Button(action: signIn) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Sign In")
                        .frame(maxWidth: .infinity)
                }
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .cornerRadius(10)
            .padding(.horizontal)
            .disabled(isLoading || identifier.isEmpty || password.isEmpty)
            
            VStack(spacing: 10) {
                Text("Don't have an account?")
                    .foregroundColor(.gray)
                
                NavigationLink(destination: SignUpView()) {
                    Text("Sign Up")
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
            }
            .padding(.top, 20)
            
            Spacer()
        }
        .padding()
        .navigationBarBackButtonHidden(false)
        .navigationDestination(isPresented: $authViewModel.isAuthenticated) {
            MainView()
        }
    }
    
    private func signIn() {
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                try await authViewModel.signIn(identifier: identifier, password: password)
            } catch AuthError.serverError(let message) {
                errorMessage = message
            } catch {
                errorMessage = "Failed to sign in. Please try again."
            }
            isLoading = false
        }
    }
}

// Helper to handle navigation
struct NavigationUtil {
    static func popToRoot() {
        findNavigationController(viewController: UIApplication.shared.windows.first?.rootViewController)?
            .popToRootViewController(animated: true)
    }
    
    static func findNavigationController(viewController: UIViewController?) -> UINavigationController? {
        guard let viewController = viewController else {
            return nil
        }
        
        if let navigationController = viewController as? UINavigationController {
            return navigationController
        }
        
        for childViewController in viewController.children {
            return findNavigationController(viewController: childViewController)
        }
        
        return nil
    }
}

#Preview {
    SignInView()
}
