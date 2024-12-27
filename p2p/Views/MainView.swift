import SwiftUI

struct MainView: View {
    @StateObject private var authViewModel = AuthViewModel.shared
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Welcome to the App!")
                    .font(.largeTitle)
                    .padding()
                
                Button(action: {
                    authViewModel.signOut()
                }) {
                    Text("Sign Out")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}
