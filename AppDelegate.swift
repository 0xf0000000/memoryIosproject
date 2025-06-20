//
// AppDelegate.swift
//
// Created by trick on 19.06.25
//

import UIKit
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        setupCrashReporting()
        return true
    }
    
    private func setupCrashReporting() {
        NSSetUncaughtExceptionHandler { exception in
            let stackTrace = exception.callStackSymbols.joined(separator: "\n")
            let report = "Crash: \(exception.name)\nReason: \(exception.reason ?? "Unknown")\nStack Trace:\n\(stackTrace)"
            UserDefaults.standard.set(report, forKey: "lastCrashReport")
        }
    }
}