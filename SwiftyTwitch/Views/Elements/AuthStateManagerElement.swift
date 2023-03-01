//
//  AuthStateManagerElement.swift
//  SwiftyTwitch
//
//  Created by Adélaïde Sky on 01/03/2023.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI

struct AuthStateManagerElement: View {
    
    @EnvironmentObject var appVM: AppViewModel
    @State var showPopover: Bool = false
    
    var body: some View {
        WebImage(url: appVM.userInfos?.profileImageURL)
            .resizable()
            .scaledToFit()
            .cornerRadius(7)
            .frame(width: 32)
            .padding(.horizontal, 5)
            .onTapGesture {
                showPopover.toggle()
            }
            .popover(isPresented: $showPopover) {
                if appVM.userInfos != nil {
                    popover
                }
            }
        
    }
    var popover: some View {
        VStack {
            AsyncImage(url: appVM.userInfos?.profileImageURL, content: { image in
                ColoredBackground(image: {
                    HStack {
                        image
                            .resizable()
                            .scaledToFill()
                    }.asNSImage()
                }()).clipped()
                    .frame(height: 60)
                
            }, placeholder: {
                Spacer()
                    .frame(height: 60)
                    .frame(maxWidth: .infinity)
            })
            HStack(alignment: .top) {
                WebImage(url: appVM.userInfos?.profileImageURL)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(7)
                    .frame(height: 50)
                    .padding(.leading, 10)
                    .padding(.trailing, 5)
                    .offset(y: -30)
                Text(appVM.userInfos!.userDisplayName)
                    .font(.title2)
                Spacer()
            }
            Button(action: {
                appVM.logOut()
            }, label: {
                Label("Sign Out", systemImage: "arrow.backward")
                    .frame(maxWidth: 180)
            })
            .padding(.horizontal, 10)
            .controlSize(.large)
        }.frame(width: 200)
            .padding(.top, -11)
            .padding(.bottom, 10)
            
    }
}

