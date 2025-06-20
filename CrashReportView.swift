//
// CrashReportView.swift
//
// Created by trick on 19.06.25
//

import SwiftUI

struct CrashReportView: View {
    @State private var crashReport: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Last Crash Report")
                    .font(.title)
                    .padding()
                    .foregroundColor(.red)
                
                ScrollView {
                    Text(crashReport)
                        .font(.system(.body, design: .monospaced))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                }
                .padding()
                
                Button(action: clearReport) {
                    Text("Clear Report")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .padding()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {}
                }
            }
            .onAppear {
                loadCrashReport()
            }
        }
    }
    
    private func loadCrashReport() {
        crashReport = UserDefaults.standard.string(forKey: "lastCrashReport") ?? "No crash reports available"
    }
    
    private func clearReport() {
        UserDefaults.standard.removeObject(forKey: "lastCrashReport")
        crashReport = "No crash reports available"
    }
}