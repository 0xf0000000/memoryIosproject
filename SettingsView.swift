//
// SettingsView.swift
//
// Created by trick on 19.06.25
//
 
import SwiftUI

struct SettingsView: View {
    @AppStorage("bgRed") private var bgRed = 0.2
    @AppStorage("bgGreen") private var bgGreen = 0.2
    @AppStorage("bgBlue") private var bgBlue = 0.3
    @Binding var rainbowMode: Bool
    @Binding var hue: Double
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Appearance")) {
                    ColorPicker("Background Color", selection: Binding(
                        get: { Color(red: bgRed, green: bgGreen, blue: bgBlue) },
                        set: { color in
                            if let components = color.cgColor?.components, components.count >= 3 {
                                bgRed = Double(components[0])
                                bgGreen = Double(components[1])
                                bgBlue = Double(components[2])
                                rainbowMode = false
                            }
                        }
                    ))
                    
                    Toggle("Rainbow Mode", isOn: $rainbowMode)
                    
                    VStack(alignment: .leading) {
                        Text("Red: \(Int(bgRed * 255))")
                        Slider(value: $bgRed, in: 0...1)
                            .disabled(rainbowMode)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Green: \(Int(bgGreen * 255))")
                        Slider(value: $bgGreen, in: 0...1)
                            .disabled(rainbowMode)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Blue: \(Int(bgBlue * 255))")
                        Slider(value: $bgBlue, in: 0...1)
                            .disabled(rainbowMode)
                    }
                }
                
                Section(header: Text("Credits")) {
                    Link(destination: URL(string: "https://www.instagram.com/danielllzzzw")!) {
                        HStack {
                            Image(systemName: "camera.fill")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.red, .orange, .yellow, .green, .blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            VStack(alignment: .leading) {
                                Text("Created by trick")
                                    .font(.headline)
                                Text("@danielllzzzw")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "arrow.up.forward.app")
                                .foregroundColor(.blue)
                        }
                        .padding(.vertical, 8)
                    }
                    
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.red, .pink],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        Text("Special thanks to all testers")
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Settings")
        }
    }
}