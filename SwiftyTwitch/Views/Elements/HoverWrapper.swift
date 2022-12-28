//
//  HoverWrapper.swift
//  SwiftyTwitch
//
//  Source: https://github.com/Flowductive/shiny-swift-ui
//
//  Created by Adélaïde Sky on 27/12/2022.
//

import Foundation
import SwiftUI

public struct HoverView<Content>: View where Content: View {
  
  // MARK: - Public Wrapped Properties
  
  /// The content to display.
  @ViewBuilder public let content: (Binding<Bool>, Bool) -> Content
  
  /// Whether the view is hovered.
  @State public var hover: Bool = false
  /// Whether the view is clicked.
  @State public var clicked: Bool = false
  
  // MARK: - Public Properties
  
  /// The action to perform on click.
  public let action: () -> Void
  /// The action to perform on hover.
  public let onHover: (Bool) -> Void

  // MARK: - Public Body View
  
  public var body: some View {
      content($hover, clicked).onHover {
          if $0 {
              usleep(300000)
              hover = $0
              onHover($0)
          } else {
              hover = $0
              onHover($0)
          }
      }
  }
  
  // MARK: - Public Initalizers
  
  public init(action: @escaping () -> Void = {}, onHover: @escaping (Bool) -> Void = { _ in }, content c: @escaping (Binding<Bool>, Bool) -> Content) {
    self.action = action
    self.onHover = onHover
    self.content = c
  }
  
  public init(action: @escaping () -> Void = {}, onHover: @escaping (Bool) -> Void = { _ in }, content c: @escaping (Binding<Bool>) -> Content) {
    self.action = action
    self.onHover = onHover
    self.content = { (hover: Binding<Bool>, click: Bool) in
        return c(hover)
    }
  }
  
}
