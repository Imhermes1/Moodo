//
//  PerformanceMonitor.swift
//  Moodo
//
//  Created by Luke Fornieri on 18/7/2025.
//

import Foundation
import UIKit
import QuartzCore
import SwiftUI

// MARK: - Performance Monitoring Utility

class PerformanceMonitor: ObservableObject {
    static let shared = PerformanceMonitor()
    
    @Published var currentFPS: Double = 60.0
    @Published var isProMotionDisplay: Bool = false
    @Published var gpuUsage: Double = 0.0
    @Published var memoryUsage: Double = 0.0
    
    private var displayLink: CADisplayLink?
    private var frameCount: Int = 0
    private var lastFrameTime: CFTimeInterval = 0
    
    private init() {
        setupDisplayLink()
        detectProMotionDisplay()
    }
    
    // MARK: - Display Link Setup
    
    private func setupDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(displayLinkFired))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    @objc private func displayLinkFired() {
        frameCount += 1
        let currentTime = CACurrentMediaTime()
        
        if currentTime - lastFrameTime >= 5.0 { // Check every 5 seconds
            currentFPS = Double(frameCount) / 5.0 // Adjust calculation for 5-second interval
            frameCount = 0
            lastFrameTime = currentTime
            
            // Monitor performance and log every 5 seconds
            monitorPerformance()
        }
    }
    
    // MARK: - ProMotion Detection
    
    private func detectProMotionDisplay() {
        if #available(iOS 15.0, *) {
            isProMotionDisplay = UIScreen.main.maximumFramesPerSecond >= 120
        } else {
            // Fallback for older iOS versions
            isProMotionDisplay = UIScreen.main.scale > 2.0
        }
        
        print("📱 ProMotion Display: \(isProMotionDisplay ? "Yes" : "No")")
        print("📱 Max FPS: \(UIScreen.main.maximumFramesPerSecond)")
    }
    
    // MARK: - Performance Monitoring
    
    private func monitorPerformance() {
        // Monitor memory usage
        let memoryInfo = getMemoryUsage()
        memoryUsage = memoryInfo.used / memoryInfo.total * 100
        
        // Log performance metrics every 5 seconds (only warn for severe drops)
        print("📊 Performance Check: FPS: \(String(format: "%.1f", currentFPS)), Memory: \(String(format: "%.1f", memoryUsage))%")
        
        if currentFPS < 30 {
            print("⚠️ Performance Warning: FPS critically low at \(currentFPS)")
        }
        
        if memoryUsage > 80 {
            print("⚠️ Memory Warning: Usage at \(memoryUsage)%")
        }
    }
    
    private func getMemoryUsage() -> (used: Double, total: Double) {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            let used = Double(info.resident_size) / 1024.0 / 1024.0 // MB
            let total = Double(ProcessInfo.processInfo.physicalMemory) / 1024.0 / 1024.0 // MB
            return (used, total)
        }
        
        return (0, 0)
    }
    
    // MARK: - Performance Optimization
    
    func optimizeForCurrentDevice() {
        if isProMotionDisplay {
            // Optimize for 120Hz displays
            print("⚡ Optimizing for ProMotion display")
        } else {
            // Optimize for 60Hz displays
            print("⚡ Optimizing for standard 60Hz display")
        }
    }
    
    func getOptimalAnimationDuration() -> Double {
        return isProMotionDisplay ? 0.15 : 0.2
    }
    
    func shouldUseGPUAcceleration() -> Bool {
        // Use GPU acceleration for complex views on capable devices
        return UIScreen.main.scale >= 2.0
    }
    
    // MARK: - Cleanup
    
    deinit {
        displayLink?.invalidate()
    }
}

// MARK: - Performance Extensions

extension View {
    func performanceMonitored() -> some View {
        self.onAppear {
            PerformanceMonitor.shared.optimizeForCurrentDevice()
        }
    }
} 
