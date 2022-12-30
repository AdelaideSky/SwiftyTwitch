//
//  isMouseHovering.swift
//  SwiftyTwitch
//
//  Created by Adélaïde Sky on 30/12/2022.
//

import Foundation
import SwiftUI

extension View {
    func onMouseMove(_ mouseMoved: @escaping (Bool) -> Void) -> some View {
        modifier(MouseInsideModifier(mouseMoved))
    }
}

struct MouseInsideModifier: ViewModifier {
    let mouseMoved: (Bool) -> Void
    
    init(_ mouseMoved: @escaping (Bool) -> Void) {
        self.mouseMoved = mouseMoved
    }
    
    func body(content: Content) -> some View {
        content.background(
            GeometryReader { proxy in
                Representable(mouseMoved: mouseMoved,
                              frame: proxy.frame(in: .global))
            }
        )
    }
    
    private struct Representable: NSViewRepresentable {
        let mouseMoved: (Bool) -> Void
        let frame: NSRect
        
        func makeCoordinator() -> Coordinator {
            let coordinator = Coordinator()
            coordinator.mouseMoved = mouseMoved
            return coordinator
        }
        
        class Coordinator: NSResponder {
            var mouseMoved: ((Bool) -> Void)?
            override func mouseMoved(with event: NSEvent) {
                mouseMoved?(true)
            }
        }
        
        func makeNSView(context: Context) -> NSView {
            let view = NSView(frame: frame)
            
            let options: NSTrackingArea.Options = [
                .mouseMoved,
                .mouseEnteredAndExited,
                .inVisibleRect,
                .activeInKeyWindow
            ]
            
            let trackingArea = NSTrackingArea(rect: frame,
                                              options: options,
                                              owner: context.coordinator,
                                              userInfo: nil)
            
            view.addTrackingArea(trackingArea)
            
            return view
        }
        
        func updateNSView(_ nsView: NSView, context: Context) {}
        
        static func dismantleNSView(_ nsView: NSView, coordinator: Coordinator) {
            nsView.trackingAreas.forEach { nsView.removeTrackingArea($0) }
        }
    }
}
