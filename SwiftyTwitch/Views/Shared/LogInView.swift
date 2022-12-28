//
//  LogInView.swift
//  SwiftyYouTube
//
//  Created by Adélaïde Sky on 24/12/2022.
//

import SwiftUI
struct LogInView: View {
    @EnvironmentObject var appVM: AppViewModel
    var body: some View {
        VStack(alignment: .leading) {
            Text("Welcome to SwiftyTwitch !")
                .font(.title)
            Text("To start using the app, please provide your Client ID and Access Token")
                .font(.subheadline)
                .opacity(0.7)
        }.frame(width: 300)
        Link(
            destination: URL(string: "https://twitchtokengenerator.com/quick/NIaMdzGYBR")!,
            label: {
                HStack {
                    Spacer()
                    Label("Generate Tokens", systemImage: "network")
                        .font(.body.bold())
                        .foregroundColor(.white)
                    Spacer()
                }
                .buttonStyle(.borderless)
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(.purple.opacity(0.25))
                .cornerRadius(7)
            }
        ).opacity(0.7)
            .padding(.vertical, 15)
            .frame(width: 300)
        VStack(alignment: .leading) {
            TextField("Client ID", text: $appVM.clientID, prompt: Text("Client ID"))
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Access Token", text: $appVM.accessToken, prompt: Text("Access Token"))
                .textFieldStyle(RoundedBorderTextFieldStyle())
            HStack {
                Button("Log In") {
                    appVM.logIn()
                }.controlSize(.large)
                if appVM.authState == .error {
                    Text("Error, bad Client ID/Access Token !")
                        .foregroundColor(.red)
                        .italic()
                        .font(.caption)
                }
            }.padding(.vertical, 5)
        }.controlSize(.large)
            .frame(width: 300)
    }
}

struct LogInView_Previews: PreviewProvider {
    static var previews: some View {
        LogInView()
    }
}
