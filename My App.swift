//
// My App.swift
//
// Created by trick on 19.06.25
//

import SwiftUI

@main
struct MemoryHackerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .onChange(of: scenePhase) { newScenePhase in
            if newScenePhase == .active {
                setupGlobalGesture()
            }
        }
    }
    
    private func setupGlobalGesture() {
        let swipeGesture = UISwipeGestureRecognizer(target: nil, action: nil)
        swipeGesture.direction = .right
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.addGestureRecognizer(swipeGesture)
        }
    }
}