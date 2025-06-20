//
// ProcessListView.swift
//
// Created by trick on 19.06.25
//

import SwiftUI

struct ProcessListView: View {
    @ObservedObject var scanner = ProcessScanner()
    @State private var searchText = ""
    @State private var selectedProcess: ProcessEntry?
    
    var filteredProcesses: [ProcessEntry] {
        if searchText.isEmpty {
            return scanner.processes
        }
        return scanner.processes.filter {
            $0.name.lowercased().contains(searchText.lowercased()) ||
            String($0.pid).contains(searchText)
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredProcesses) { process in
                    processRow(process: process)
                        .swipeActions {
                            Button("Attach") {
                                selectedProcess = process
                                openMemoryEditor()
                            }
                            .tint(.purple)
                        }
                }
            }
            .searchable(text: $searchText)
            .listStyle(.insetGrouped)
            .navigationTitle("Running Processes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { scanner.refresh() }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .sheet(item: $selectedProcess) { process in
                MemoryEditorView(pid: process.pid, showEditor: .constant(false))
            }
        }
    }
    
    private func processRow(process: ProcessEntry) -> some View {
        VStack(alignment: .leading) {
            Text(process.name)
                .font(.headline)
            Text("PID: \(process.pid)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            selectedProcess = process
        }
    }
    
    private func openMemoryEditor() {
        if let process = selectedProcess {
            let url = URL(string: "memoryeditor://\(process.pid)")!
            UIApplication.shared.open(url)
        }
    }
}