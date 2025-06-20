//
// ProcessScanner.swift
//
// Created by trick on 19.06.25
//

import Foundation
import Combine

@_silgen_name("proc_listpids")
func proc_listpids(_ type: Int32, _ typeinfo: UInt32, _ buffer: UnsafeMutableRawPointer?, _ buffersize: Int32) -> Int32

@_silgen_name("proc_pidpath")
func proc_pidpath(_ pid: Int32, _ buffer: UnsafeMutablePointer<CChar>?, _ buffersize: UInt32) -> Int32

class ProcessScanner: ObservableObject {
    @Published var processes: [ProcessEntry] = []
    
    func refresh() {
        var newProcesses: [ProcessEntry] = []
        let maxPids = 9999
        var pids = [Int32](repeating: 0, count: maxPids)
        
        let count = proc_listpids(1, 0, &pids, Int32(maxPids * MemoryLayout<Int32>.size))
        
        for i in 0..<Int(count) {
            let pid = pids[i]
            if pid == 0 { continue }
            
            var path = [CChar](repeating: 0, count: 4096)
            if proc_pidpath(pid, &path, UInt32(path.count)) > 0 {
                let name = String(cString: path).components(separatedBy: "/").last ?? "Unknown"
                newProcesses.append(ProcessEntry(id: pid, pid: pid, name: name))
            }
        }
        
        processes = newProcesses.sorted { $0.name < $1.name }
    }
}

struct ProcessEntry: Identifiable {
    let id: Int32
    let pid: Int32
    let name: String
}