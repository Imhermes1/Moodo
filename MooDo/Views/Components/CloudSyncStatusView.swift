//
//  CloudSyncStatusView.swift
//  Moodo
//
//  Created by Luke Fornieri on 18/7/2025.
//

import SwiftUI

struct CloudSyncStatusView: View {
    @StateObject private var cloudKitManager = CloudKitManager.shared
    
    var body: some View {
        VStack {
            if case .syncing = cloudKitManager.syncStatus {
                HStack(spacing: 8) {
                    ProgressView()
                        .scaleEffect(0.7)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    
                    Text("Syncing to iCloud...")
                        .font(.caption)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.thinMaterial)
                        .opacity(0.4)
                )
                .padding(.top, 120)
                .animation(.easeInOut(duration: 0.3), value: cloudKitManager.syncStatus)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    CloudSyncStatusView()
        .background(UniversalBackground())
} 