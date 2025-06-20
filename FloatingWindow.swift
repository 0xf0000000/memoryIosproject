//
// FloatingWindow.swift
//
// Created by trick on 19.06.25
//

import SwiftUI

struct FloatingWindow<Content: View>: View {
    @ViewBuilder let content: Content
    @State private var offset = CGSize.zero
    @State private var isDragging = false
    @State private var floatingPosition = CGPoint(x: UIScreen.main.bounds.width - 60, y: UIScreen.main.bounds.height/2)
    
    var body: some View {
        content
            .frame(width: 300, height: 400)
            .background(Color(.systemBackground))
            .cornerRadius(15)
            .shadow(radius: 15)
            .position(floatingPosition)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        floatingPosition = gesture.location
                        isDragging = true
                    }
                    .onEnded { _ in
                        isDragging = false
                    }
            )
            .opacity(isDragging ? 0.9 : 1.0)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.purple, lineWidth: 2)
            )
    }
}