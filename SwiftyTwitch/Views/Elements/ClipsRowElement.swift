//
//  ClipsRowElement.swift
//  SwiftyTwitch
//
//  Created by Adélaïde Sky on 28/12/2022.
//

import Foundation
import SwiftUI
import SwiftTwitch

struct ClipsRowElement: View {
    var title: String
    var clips: [ClipData]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title)
                .bold()
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(clips, id: \.clipId) { clip in
                        ClipElement(clip: clip).padding(.horizontal, 5)
                            .padding(.vertical, 2)
                    }
                }
            }
            
        }.padding(.horizontal)
    }
}

struct ClipElement: View {
    var clip: ClipData
    
    var body: some View {
        HoverView(delay: false) { isHover in
            VStack {
                VStack(alignment: .leading) {
                    ZStack {
                        AsyncImage(url: clip.thumbnailURL, content: { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(5)
                        }, placeholder: {
                            ProgressView().scaleEffect(0.5)
                                .frame(width: 320, height: 180)
                        })
                        VStack(alignment: .leading) {
                            Spacer().frame(maxWidth: .infinity, maxHeight: .infinity)
                            HStack {
                                Text("\(clip.viewCount.customFormatted) views")
                                    .padding(3)
                                    .background() {
                                        VisualEffectView(material: .popover, blendingMode: .withinWindow)
                                            .cornerRadius(5)
                                    }
                                Spacer().frame(maxWidth: .infinity)
                                Text(clip.creationDate.timeAgoDisplay())
                                    .padding(3)
                                    .background() {
                                        VisualEffectView(material: .popover, blendingMode: .withinWindow)
                                            .cornerRadius(5)
                                    }
                            }
                        }.padding(10)
                            .shadow(radius: 3)
                    }.frame(width: 320, height: 180)
                    .scaleEffect(isHover.wrappedValue ? 1.03 : 1)
                    .shadow(radius: isHover.wrappedValue ? 3 : 0)
                    .animation(.easeInOut(duration: 0.3), value: isHover.wrappedValue)
                    VStack(alignment: .leading) {
                        Text(clip.title)
                            .font(.headline)
                            .lineLimit(2)
                        HStack {
                            Text(clip.broadcasterName)
                                .opacity(0.7)
                            Spacer()
                            Text("Clipped by \(clip.creatorName)")
                                .opacity(0.7)
                        }
                    }
                }.frame(width: 320)
                    .padding(10)
            }
            .contextMenu() {
                Button(action: {
                    clip.clipURL.absoluteString.copy()
                }, label: {
                    Label("Copy link to clipboard", systemImage: "doc.on.doc")
                })
                ShareLink(item: clip.clipURL)
                Divider()
                Button(action: {
                    NSWorkspace.shared.open(clip.clipURL)
                }, label: {
                    Label("Open link", systemImage: "globe")
                })
            }
            .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(.separator, lineWidth: 1)
                    
                )
            .background() {
                RoundedRectangle(cornerRadius: 5)
                    .fill(.separator)
                    .opacity(0.2)
            }
        }
    }
}
