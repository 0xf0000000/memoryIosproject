//
// MemoryEditorView.swift
//
// Created by trick on 19.06.25
//

import SwiftUI

struct MemoryEditorView: View {
    @ObservedObject var editor = MemoryEditor.shared
    var pid: Int32
    @Binding var showEditor: Bool
    
    @State private var searchPattern = ""
    @State private var newValue = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var searchType: MemoryEditor.SearchType = .fuzzy
    @State private var showMemoryView = false
    @State private var selectedAddress: UInt64 = 0
    @State private var showAdvanced = false
    @State private var scanExecutableOnly = false
    @State private var caseSensitive = false
    @State private var maxResults = 100
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    headerView
                    searchSection
                    resultsSection
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text("Memory Editor").font(.headline)
                        Text("PID: \(pid)").font(.caption)
                    }
                }
            }
            .alert("Result", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .sheet(isPresented: $showMemoryView) {
                MemoryViewer(address: selectedAddress, memory: editor.readMemory(pid: pid, address: selectedAddress, size: 64) ?? [])
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            Button(action: { showEditor = false }) {
                Image(systemName: "chevron.left")
                    .font(.headline)
            }
            Spacer()
            Toggle("Advanced", isOn: $showAdvanced)
                .toggleStyle(.switch)
                .frame(width: 120)
        }
        .padding(.bottom, 10)
    }
    
    private var searchSection: some View {
        VStack(spacing: 12) {
            Picker("Search Type", selection: $searchType) {
                Text("Hex").tag(MemoryEditor.SearchType.exact)
                Text("Fuzzy").tag(MemoryEditor.SearchType.fuzzy)
                Text("String").tag(MemoryEditor.SearchType.string)
                Text("Number").tag(MemoryEditor.SearchType.number)
            }
            .pickerStyle(SegmentedPickerStyle())
            
            TextField(searchType == .string ? "Enter string" : searchType == .number ? "Enter number" : "Hex pattern (A0 B0 ?? FF)", 
                     text: $searchPattern)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
            
            Button(action: performSearch) {
                Label("Search Memory", systemImage: "magnifyingglass")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.purple)
            .controlSize(.large)
            .disabled(editor.isSearching)
            
            if editor.isSearching {
                ProgressView(value: editor.searchProgress)
                    .padding(.top, 5)
            }
            
            if showAdvanced {
                advancedOptions
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    private var advancedOptions: some View {
        VStack(spacing: 10) {
            Toggle("Scan Executable Only", isOn: $scanExecutableOnly)
            Toggle("Case Sensitive", isOn: $caseSensitive)
            Stepper("Max Results: \(maxResults)", value: $maxResults, in: 10...1000, step: 10)
        }
        .font(.footnote)
    }
    
    private var resultsSection: some View {
        VStack {
            HStack {
                Text("Results (\(editor.searchResults.count))")
                    .font(.headline)
                Spacer()
                Button("Clear") {
                    editor.searchResults = []
                }
                .disabled(editor.searchResults.isEmpty)
            }
            
            if editor.searchResults.isEmpty {
                Text(editor.isSearching ? "Searching..." : "No results yet. Perform a search first.")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(editor.searchResults.prefix(maxResults), id: \.self) { address in
                        memoryRow(for: address)
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    private func memoryRow(for address: UInt64) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(String(format: "0x%llX", address))
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.purple)
                
                Spacer()
                
                Button {
                    selectedAddress = address
                    showMemoryView = true
                } label: {
                    Image(systemName: "eye")
                        .foregroundColor(.purple)
                }
            }
            
            if showAdvanced {
                HStack {
                    TextField("New value", text: $newValue)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button("Write") {
                        writeMemory(at: address)
                    }
                    .buttonStyle(.bordered)
                    .tint(.purple)
                }
            }
        }
        .padding()
        .background(Color(.tertiarySystemGroupedBackground))
        .cornerRadius(8)
    }
    
    private func performSearch() {
        let results = editor.searchMemory(pid: pid, pattern: searchPattern, type: searchType)
        alertMessage = "Found \(results.count) matches"
        showAlert = true
    }
    
    private func writeMemory(at address: UInt64) {
        let bytes: [UInt8]
        
        switch searchType {
        case .string:
            bytes = caseSensitive ? Array(newValue.utf8) : Array(newValue.lowercased().utf8)
        case .number:
            if let number = Int64(newValue) {
                bytes = withUnsafeBytes(of: number.littleEndian) { Array($0) }
            } else {
                bytes = []
            }
        default:
            bytes = newValue.split(separator: " ").compactMap { UInt8($0, radix: 16) }
        }
        
        if !bytes.isEmpty {
            if editor.writeMemory(pid: pid, address: address, value: bytes) {
                alertMessage = "Memory modified successfully"
            } else {
                alertMessage = "Failed to modify memory"
            }
            showAlert = true
        }
    }
}

struct MemoryViewer: View {
    var address: UInt64
    var memory: [UInt8]
    @State private var columnCount = 8
    
    var body: some View {
        VStack {
            HStack {
                Text(String(format: "Memory at 0x%llX", address))
                    .font(.headline)
                
                Spacer()
                
                Stepper("Columns: \(columnCount)", value: $columnCount, in: 4...16, step: 2)
            }
            .padding()
            
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 8) {
                    ForEach(0..<memory.count/columnCount, id: \.self) { row in
                        memoryRow(row: row)
                    }
                }
                .padding()
            }
        }
    }
    
    private func memoryRow(row: Int) -> some View {
        let offset = row * columnCount
        let rowAddress = address + UInt64(offset)
        
        return HStack(alignment: .top, spacing: 8) {
            Text(String(format: "0x%llX:", rowAddress))
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.purple)
            
            ForEach(0..<min(columnCount, memory.count - offset), id: \.self) { col in
                Text(String(format: "%02X", memory[offset + col]))
                    .font(.system(.body, design: .monospaced))
            }
            
            Spacer()
            
            ForEach(0..<min(columnCount, memory.count - offset), id: \.self) { col in
                let byte = memory[offset + col]
                let char = (byte >= 32 && byte <= 126) ? String(UnicodeScalar(byte)) : "."
                Text(char)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(byte == 0 ? .red : .primary)
            }
        }
    }
}