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
    @State var test: String = ""
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
                        .toolbar() {
                            ToolbarItemGroup {
                                Spacer()
                                TextField("Search anything", text: $test)
                                    .controlSize(.large)
                                    .padding(8)
                                    .frame(width: 250)
                                    .background(RoundedRectangle(cornerRadius: 8)
                                                                .stroke(Color.clear)
                                                                .background(Color.black.opacity(0.2).cornerRadius(8)))
                                    .textFieldStyle(PlainTextFieldStyle())
                            }
                        }
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
