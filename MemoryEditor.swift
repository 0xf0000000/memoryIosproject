

//
// MemoryEditor.swift
//
// Created by trick on 19.06.25
//

import Foundation
import MachO

@_silgen_name("task_for_pid")
func task_for_pid(target_tport: mach_port_t, pid: Int32, task: UnsafeMutablePointer<task_t>) -> kern_return_t

@_silgen_name("mach_vm_read")
func mach_vm_read(target_task: task_t, address: mach_vm_address_t, size: mach_vm_size_t, data: UnsafeMutablePointer<UnsafeMutableRawPointer?>, dataCnt: UnsafeMutablePointer<mach_msg_type_number_t>) -> kern_return_t

@_silgen_name("mach_vm_write")
func mach_vm_write(target_task: task_t, address: mach_vm_address_t, data: UnsafeRawPointer, dataCnt: mach_msg_type_number_t) -> kern_return_t

@_silgen_name("vm_region_64")
func vm_region_64(target_task: task_t, address: UnsafeMutablePointer<mach_vm_address_t>, size: UnsafeMutablePointer<mach_vm_size_t>, flavor: Int32, info: UnsafeMutablePointer<Int32>, infoCnt: UnsafeMutablePointer<mach_msg_type_number_t>, object_name: UnsafeMutablePointer<mach_port_t>) -> kern_return_t

class MemoryEditor: ObservableObject {
    static let shared = MemoryEditor()
    @Published private var savedValues: [UInt64: [UInt8]] = [:]
    @Published var searchResults: [UInt64] = []
    @Published var currentPID: Int32 = 0
    @Published var searchProgress: Double = 0
    @Published var isSearching = false
    
    enum SearchType {
        case exact
        case fuzzy
        case string
        case number
    }
    
    func searchMemory(pid: Int32, pattern: String, type: SearchType = .fuzzy) -> [UInt64] {
        currentPID = pid
        var results = [UInt64]()
        let regions = getMemoryRegions(pid: pid)
        let totalRegions = regions.count
        var processedRegions = 0
        
        isSearching = true
        searchProgress = 0
        
        for region in regions {
            if let memory = readMemory(pid: pid, address: region.start, size: region.size) {
                switch type {
                case .exact, .fuzzy:
                    let bytes = pattern.split(separator: " ").map { $0 == "??" ? nil : UInt8($0, radix: 16) }
                    for i in 0..<memory.count - bytes.count {
                        var match = true
                        for j in 0..<bytes.count {
                            if let byte = bytes[j], memory[i+j] != byte {
                                match = false
                                break
                            }
                        }
                        if match {
                            results.append(region.start + UInt64(i))
                        }
                    }
                    
                case .string:
                    if let patternData = pattern.data(using: .utf8) {
                        let patternBytes = [UInt8](patternData)
                        for i in 0..<memory.count - patternBytes.count {
                            var match = true
                            for j in 0..<patternBytes.count {
                                if memory[i+j] != patternBytes[j] {
                                    match = false
                                    break
                                }
                            }
                            if match {
                                results.append(region.start + UInt64(i))
                            }
                        }
                    }
                    
                case .number:
                    if let number = Int64(pattern) {
                        let numberBytes = withUnsafeBytes(of: number.littleEndian) { Array($0) }
                        for i in 0..<memory.count - numberBytes.count {
                            var match = true
                            for j in 0..<numberBytes.count {
                                if memory[i+j] != numberBytes[j] {
                                    match = false
                                    break
                                }
                            }
                            if match {
                                results.append(region.start + UInt64(i))
                            }
                        }
                    }
                }
            }
            
            processedRegions += 1
            searchProgress = Double(processedRegions) / Double(totalRegions)
        }
        
        searchResults = results
        isSearching = false
        return results
    }
    
    func writeMemory(pid: Int32, address: UInt64, value: [UInt8]) -> Bool {
        var task: task_t = 0
        guard task_for_pid(mach_task_self_, pid, &task) == KERN_SUCCESS else { return false }
        if savedValues[address] == nil {
            savedValues[address] = readMemory(pid: pid, address: address, size: value.count)
        }
        return value.withUnsafeBytes { 
            mach_vm_write(target_task: task, address: address, data: $0.baseAddress!, dataCnt: mach_msg_type_number_t(value.count)) == KERN_SUCCESS
        }
    }
    
    func restoreMemory(pid: Int32, address: UInt64) -> Bool {
        guard let original = savedValues[address] else { return false }
        return writeMemory(pid: pid, address: address, value: original)
    }
    
    func readMemory(pid: Int32, address: UInt64, size: Int) -> [UInt8]? {
        var task: task_t = 0
        guard task_for_pid(mach_task_self_, pid, &task) == KERN_SUCCESS else { return nil }
        var data: UnsafeMutableRawPointer?
        var dataSize: mach_msg_type_number_t = 0
        guard mach_vm_read(target_task: task, address: address, size: mach_vm_size_t(size), data: &data, dataCnt: &dataSize) == KERN_SUCCESS else { return nil }
        defer { vm_deallocate(mach_task_self_, vm_address_t(bitPattern: data), vm_size_t(dataSize)) }
        return Array(UnsafeBufferPointer(start: data?.assumingMemoryBound(to: UInt8.self), count: Int(dataSize)))
    }
    
    private func getMemoryRegions(pid: Int32) -> [(start: UInt64, size: Int)] {
        var regions = [(UInt64, Int)]()
        var task: task_t = 0
        guard task_for_pid(mach_task_self_, pid, &task) == KERN_SUCCESS else { return regions }
        var address: mach_vm_address_t = 0
        var size: mach_vm_size_t = 0
        var info = vm_region_basic_info_64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_region_basic_info_64>.stride / MemoryLayout<Int32>.stride)
        var object_name: mach_port_t = 0
        
        while true {
            let result = withUnsafeMutablePointer(to: &info) {
                $0.withMemoryRebound(to: Int32.self, capacity: Int(count)) {
                    vm_region_64(
                        target_task: task,
                        address: &address,
                        size: &size,
                        flavor: VM_REGION_BASIC_INFO_64,
                        info: $0,
                        infoCnt: &count,
                        object_name: &object_name
                    )
                }
            }
            if result != KERN_SUCCESS { break }
            regions.append((address, Int(size)))
            address += size
        }
        return regions
    }
}