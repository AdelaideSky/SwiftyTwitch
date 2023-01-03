//
//  HomeScreenView.swift
//  SwiftyTwitch
//
//  Created by Adélaïde Sky on 03/01/2023.
//

import Foundation
import SwiftUI

struct HomeScreenView: View {
    @EnvironmentObject var navigationVM: NavigationViewModel
    
    var body: some View {
        VStack {
            Text("WIP.")
        }
    }
}


struct SnapCarousel: View {
    @EnvironmentObject var navigationVM: NavigationViewModel
    @EnvironmentObject var carrouselState: CarouselModel
    @State var follows: [Follow]
    var body: some View {
        let spacing: CGFloat = 16
        let widthOfHiddenCards: CGFloat = 32
        let cardHeight: CGFloat = 279
        
        
        return Canvas {
            /// TODO: find a way to avoid passing same arguments to Carousel and Item
            Carousel(
                numberOfItems: CGFloat(follows.count),
                spacing: spacing,
                widthOfHiddenCards: widthOfHiddenCards
            ) {
                ForEach(follows, id: \.self) { follow in
                    Item(
                        _id: Int.random(in: 1...1000),
                        spacing: spacing,
                        widthOfHiddenCards: widthOfHiddenCards,
                        cardHeight: cardHeight
                    ) {
                        VStack {
                            if !follow.streamData!.thumbnailURLString.isEmpty {
                                AsyncImage(url: URL(string: follow.streamData!.thumbnailURLString.replacingOccurrences(of: "{width}", with: "440").replacingOccurrences(of: "{height}", with: "248"))!, content: { image in
                                    image.resizable()
                                        .scaledToFit()
                                }, placeholder: {
                                    Spacer()
                                }).frame(width: 440, height: 248)
                            }
                        }
                    }
                    .cornerRadius(8)
                    .shadow(color: Color.gray, radius: 4, x: 0, y: 4)
                    .transition(AnyTransition.slide)
                    .animation(.spring())
                }
            }
        }
    }
}

public class CarouselModel: ObservableObject {
    @Published var activeCard: Int = 0
    @Published var screenDrag: Float = 0.0
}

struct Carousel<Items : View> : View {
    let items: Items
    let numberOfItems: CGFloat
    let spacing: CGFloat
    let widthOfHiddenCards: CGFloat
    let totalSpacing: CGFloat
    let cardWidth: CGFloat
    
    @GestureState var isDetectingLongPress = false
    
    @EnvironmentObject var UIState: CarouselModel
        
    @inlinable public init(
        numberOfItems: CGFloat,
        spacing: CGFloat,
        widthOfHiddenCards: CGFloat,
        @ViewBuilder _ items: () -> Items) {
        
        self.items = items()
        self.numberOfItems = numberOfItems
        self.spacing = spacing
        self.widthOfHiddenCards = widthOfHiddenCards
        self.totalSpacing = (numberOfItems - 1) * spacing
        self.cardWidth = (NSScreen.main?.frame.width ?? 0) - (widthOfHiddenCards*2) - (spacing*2)
        
    }
    
    var body: some View {
        let totalCanvasWidth: CGFloat = (cardWidth * numberOfItems) + totalSpacing
        let xOffsetToShift = (totalCanvasWidth - (NSScreen.main?.frame.width ?? 0)) / 2
        let leftPadding = widthOfHiddenCards + spacing
        let totalMovement = cardWidth + spacing
                
        let activeOffset = xOffsetToShift + (leftPadding) - (totalMovement * CGFloat(UIState.activeCard))
        let nextOffset = xOffsetToShift + (leftPadding) - (totalMovement * CGFloat(UIState.activeCard) + 1)

        var calcOffset = Float(activeOffset)
        
        if (calcOffset != Float(nextOffset)) {
            calcOffset = Float(activeOffset) + UIState.screenDrag
        }
        
        return HStack(alignment: .center, spacing: spacing) {
            items
        }
        .offset(x: CGFloat(calcOffset), y: 0)
        .gesture(DragGesture().updating($isDetectingLongPress) { currentState, gestureState, transaction in
            self.UIState.screenDrag = Float(currentState.translation.width)
            
        }.onEnded { value in
            self.UIState.screenDrag = 0
            
            if (value.translation.width < -50) &&  self.UIState.activeCard < Int(numberOfItems) - 1 {
                self.UIState.activeCard = self.UIState.activeCard + 1
            }
            
            if (value.translation.width > 50) && self.UIState.activeCard > 0 {
                self.UIState.activeCard = self.UIState.activeCard - 1
            }
        })
    }
}

struct Canvas<Content : View> : View {
    let content: Content
    @EnvironmentObject var UIState: CarouselModel
    
    @inlinable init(@ViewBuilder _ content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
            .background(Color.white.edgesIgnoringSafeArea(.all))
    }
}

struct Item<Content: View>: View {
    @EnvironmentObject var UIState: CarouselModel
    let cardWidth: CGFloat
    let cardHeight: CGFloat

    var _id: Int
    var content: Content

    @inlinable public init(
        _id: Int,
        spacing: CGFloat,
        widthOfHiddenCards: CGFloat,
        cardHeight: CGFloat,
        @ViewBuilder _ content: () -> Content
    ) {
        self.content = content()
        self.cardWidth = (NSScreen.main?.frame.width ?? 0) - (widthOfHiddenCards*2) - (spacing*2)
        self.cardHeight = cardHeight
        self._id = _id
    }

    var body: some View {
        content
            .frame(width: cardWidth, height: _id == UIState.activeCard ? cardHeight : cardHeight - 60, alignment: .center)
    }
}
