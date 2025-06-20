//
// ContentView.swift
//
// Created by trick on 19.06.25
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var showFloating = false
    @State private var floatingPID: Int32 = 0
    @AppStorage("bgRed") private var bgRed = 0.0
    @AppStorage("bgGreen") private var bgGreen = 0.0
    @AppStorage("bgBlue") private var bgBlue = 0.0
    @AppStorage("rainbowMode") private var rainbowMode = false
    @State private var hue: Double = 0
    @State private var timer: Timer?
    
    var body: some View {
        ZStack {
            Color(red: bgRed, green: bgGreen, blue: bgBlue)
                .ignoresSafeArea()
            
            TabView(selection: $selectedTab) {
                ProcessListView()
                    .tabItem { 
                        Label("Processes", systemImage: "list.dash") 
                    }
                    .tag(0)
                
                MemoryView()
                    .tabItem { 
                        Label("Memory", systemImage: "memorychip") 
                    }
                    .tag(1)
                
                SettingsView(rainbowMode: $rainbowMode, hue: $hue)
                    .tabItem { 
                        Label("Settings", systemImage: "gearshape") 
                    }
                    .tag(2)
            }
            .accentColor(.purple)
            
            if showFloating {
                FloatingWindow {
                    MemoryEditorView(pid: floatingPID, showEditor: $showFloating)
                }
            }
        }
        .onOpenURL { url in
            if url.scheme == "memoryeditor", let pid = Int32(url.host ?? "") {
                floatingPID = pid
                showFloating = true
            }
        }
        .onChange(of: rainbowMode) { newValue in
            if newValue {
                startRainbowMode()
            } else {
                stopRainbowMode()
            }
        }
    }
    
    private func startRainbowMode() {
        timer?.invalidate()
        hue = 0
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            withAnimation(.linear(duration: 0.05)) {
                hue = (hue + 0.01).truncatingRemainder(dividingBy: 1.0)
                
                let color = UIColor(hue: CGFloat(hue), saturation: 1.0, brightness: 1.0, alpha: 1.0)
                var r: CGFloat = 0
                var g: CGFloat = 0
                var b: CGFloat = 0
                color.getRed(&r, green: &g, blue: &b, alpha: nil)
                
                bgRed = Double(r)
                bgGreen = Double(g)
                bgBlue = Double(b)
            }
        }
    }
    
    private func stopRainbowMode() {
        timer?.invalidate()
        timer = nil
    }
}