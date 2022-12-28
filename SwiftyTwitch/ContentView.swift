//
//  ContentView.swift
//  SwiftyTwitch
//
//  Created by Adélaïde Sky on 26/12/2022.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appVM: AppViewModel
    var navVM = NavigationViewModel()
    var body: some View {
        VStack {
            switch appVM.authState {
                case .none:
                    LoadingElement()
                case .loggedOut:
                    LogInView()
                case .loggedIn:
                    NavigationView()
                        .environmentObject(navVM)
                case .error:
                    LogInView()
            }
        }.onAppear() {
            appVM.restoreLoginState()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
