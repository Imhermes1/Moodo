//
//  ViewModifiers.swift
//  Moodo
//
//  Created by Luke Fornieri on 18/7/2025.
//

import SwiftUI

// MARK: - Performance Optimization Modifiers

struct PerformanceOptimizedModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .drawingGroup() // GPU rendering for complex views
            .compositingGroup() // Optimize layer compositing
    }
}

struct ReducedMotionModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    func body(content: Content) -> some View {
        if reduceMotion {
            content
                .animation(nil, value: UUID()) // Disable animations
        } else {
            content
        }
    }
}

struct OptimizedGlassEffect: ViewModifier {
    let opacity: Double
    let cornerRadius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .opacity(opacity)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

// MARK: - GPU Acceleration Modifiers

struct GPUAcceleratedModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .drawingGroup() // Force GPU rendering
    }
}

struct ProMotionOptimizedModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .drawingGroup() // GPU acceleration
            .compositingGroup() // Layer optimization
    }
}

// MARK: - Extension for Easy Usage

extension View {
    func performanceOptimized() -> some View {
        modifier(PerformanceOptimizedModifier())
    }
    
    func reducedMotion() -> some View {
        modifier(ReducedMotionModifier())
    }
    
    func optimizedGlass(opacity: Double = 0.4, cornerRadius: CGFloat = 16) -> some View {
        modifier(OptimizedGlassEffect(opacity: opacity, cornerRadius: cornerRadius))
    }
    
    func gpuAccelerated() -> some View {
        modifier(GPUAcceleratedModifier())
    }
    
    func proMotionOptimized() -> some View {
        modifier(ProMotionOptimizedModifier())
    }
} 