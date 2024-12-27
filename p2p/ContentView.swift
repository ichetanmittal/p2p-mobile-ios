//
//  ContentView.swift
//  p2p
//
//  Created by Chetan Mittal on 2024/12/27.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel.shared
    
    var body: some View {
        NavigationStack {
            Group {
                if authViewModel.isAuthenticated {
                    MainView()
                } else {
                    SignInView()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
