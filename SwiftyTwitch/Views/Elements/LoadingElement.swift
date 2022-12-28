//
//  LoadingElement.swift
//  SwiftyYouTube
//
//  Created by Adélaïde Sky on 24/12/2022.
//

import SwiftUI

struct LoadingElement: View {
    
    var body: some View {
        VStack {
            ProgressView().scaleEffect(0.5)
            Text("LOADING")
                .font(.footnote)
                .opacity(0.5)
        }
    }
}

