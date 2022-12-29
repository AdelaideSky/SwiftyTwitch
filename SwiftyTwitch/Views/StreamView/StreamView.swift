//
//  StreamView.swift
//  SwiftyTwitch
//
//  Created by Adélaïde Sky on 29/12/2022.
//

import Foundation
import SwiftUI

struct StreamView: View {
    @EnvironmentObject var appVM: AppViewModel
    var body: some View {
        VStack {
            if appVM.streamPlayer != nil {
                PlayerView()
                    .environmentObject(appVM.streamPlayer!)
                    .aspectRatio(16/9, contentMode: .fit)
                    .background() {
                        AsyncImage(url: appVM.streamPlayer!.channel.userData.profileImageURL, content: { image in
                            ColoredBackground(image: {
                                HStack {
                                    image
                                        .resizable()
                                        .scaledToFill()
                                }.asNSImage()
                            }())
                            
                        }, placeholder: {
                            Spacer()
                        })
                    }
            }
        }.padding(20)

    }
}
