//
// MemoryView.swift
//
// Created by trick on 19.06.25
//

import SwiftUI

struct MemoryView: View {
    @State private var pidInput = ""
    @State private var patternInput = ""
    @State private var showEditor = false
    @State private var selectedPID: Int32 = 0
    @State private var showFloating = false
    @State private var showCrashReport = false
    @State private var quickProcesses = [
        ProcessEntry(id: 123, pid: 123, name: "GameProcess"),
        ProcessEntry(id: 456, pid: 456, name: "AppProcess")
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(spacing: 20) {
                        quickAccessSection
                        inputSection
                        actionButtons
                    }
                    .padding()
                }
                .navigationTitle("Memory Editor")
                .sheet(isPresented: $showEditor) {
                    if selectedPID != 0 {
                        MemoryEditorView(pid: selectedPID, showEditor: $showEditor)
                    }
                }
                .sheet(isPresented: $showCrashReport) {
                    CrashReportView()
                }
                
                if showFloating {
                    FloatingWindow {
                        MemoryEditorView(pid: selectedPID, showEditor: $showFloating)
                    }
                    .transition(.scale)
                    .zIndex(1)
                }
            }
            .background(Color(.systemGroupedBackground))
        }
    }
    
    private var quickAccessSection: some View {
        VStack(alignment: .leading) {
            Text("Quick Access")
                .font(.headline)
                .padding(.leading, 5)
            
            ForEach(quickProcesses) { process in
                Button(action: {
                    selectedPID = process.pid
                    showFloating = true
                }) {
                    HStack {
                        Text(process.name)
                        Spacer()
                        Text("PID: \(process.pid)")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.purple, lineWidth: 1)
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var inputSection: some View {
        VStack(spacing: 15) {
            TextField("Enter PID", text: $pidInput)
                .keyboardType(.numberPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            TextField("Search Pattern (A0 B0 ?? FF)", text: $patternInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
        }
    }
    
    private var actionButtons: some View {
        HStack(spacing: 15) {
            Button("Search") {
                if let pid = Int32(pidInput) {
                    selectedPID = pid
                    showEditor = true
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.purple)
            
            Button("Floating") {
                if let pid = Int32(pidInput) {
                    selectedPID = pid
                    showFloating = true
                }
            }
            .buttonStyle(.bordered)
            .tint(.purple)
            
            Button("Crash") {
                showCrashReport = true
            }
            .buttonStyle(.bordered)
            .tint(.red)
        }
        .padding(.top, 10)
    }
}