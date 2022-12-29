//
//  VideosRowElement.swift
//  SwiftyTwitch
//
//  Created by Adélaïde Sky on 28/12/2022.
//

import Foundation
import SwiftUI
import SwiftTwitch

struct VideosRowElement: View {
    var title: String
    var videos: [VideoData]
    
    init(_ title: String, videos: [VideoData]) {
        self.title = title
        self.videos = videos
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title)
                .bold()
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(videos, id: \.id) { video in
                        if video.videoType == .archive {
                            VideoElement(video: video).padding(.horizontal, 5)
                                .padding(.vertical, 2)
                        }
                    }
                }
            }
            
        }.padding(.horizontal)
    }
}

struct VideoElement: View {
    var video: VideoData
    
    var body: some View {
        HoverView(delay: false) { isHover in
            VStack {
                VStack(alignment: .leading) {
                    ZStack {
                        
                        AsyncImage(url: URL(string: video.thumbnailURLString.replacing("%{width}", with: "320").replacing("%{height}", with: "180")), content: { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(5)
                        }, placeholder: {
                            ProgressView().scaleEffect(0.5)
                                .frame(width: 320, height: 180)
                        })
                        VStack(alignment: .leading) {
                            Text(video.durationString.replacingOccurrences(of: "h", with: ":").replacingOccurrences(of: "m", with: ":").dropLast())
                                .padding(3)
                                .background() {
                                    VisualEffectView(material: .popover, blendingMode: .withinWindow)
                                        .cornerRadius(5)
                                }
                            Spacer().frame(maxWidth: .infinity)
                            HStack {
                                Text("\(video.viewCount.customFormatted) views")
                                    .padding(3)
                                    .background() {
                                        VisualEffectView(material: .popover, blendingMode: .withinWindow)
                                            .cornerRadius(5)
                                    }
                                Spacer().frame(maxWidth: .infinity)
                                Text(video.publishedDate.timeAgoDisplay())
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
                        Text(video.title)
                            .font(.headline)
                            .lineLimit(2)
                        Text(video.ownerName)
                            .opacity(0.7)
                    }
                }.frame(width: 320)
                    .padding(10)
            }
            .contextMenu() {
                Button(action: {
                    video.url.absoluteString.copy()
                }, label: {
                    Label("Copy link to clipboard", systemImage: "doc.on.doc")
                })
                ShareLink(item: video.url)
                Divider()
                Button(action: {
                    NSWorkspace.shared.open(video.url)
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
