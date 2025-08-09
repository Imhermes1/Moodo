//
//  NotesSectionView.swift
//  Moodo
//
//  Created by ChatGPT on 2025-02-15.
//

import SwiftUI

/// Displays recent task notes on the home screen.
struct NotesSectionView: View {
    @ObservedObject var taskManager: TaskManager

    private struct NoteItem: Identifiable {
        let note: TaskNote
        let taskTitle: String
        var id: UUID { note.id }
    }

    private var notes: [NoteItem] {
        taskManager.tasks.flatMap { task in
            task.notes.map { NoteItem(note: $0, taskTitle: task.title) }
        }
        .sorted { $0.note.timestamp > $1.note.timestamp }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Notes")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)

            if notes.isEmpty {
                Text("No notes yet")
                    .font(.callout)
                    .foregroundColor(.secondary)
            } else {
                ForEach(notes.prefix(5)) { item in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.note.text)
                            .font(.body)
                            .foregroundColor(.primary)
                            .lineLimit(3)

                        Text(item.taskTitle)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.08))
                    )
                }
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackground)
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        .shadow(color: .black.opacity(0.04), radius: 16, x: 0, y: 8)
        .shadow(color: .white.opacity(0.1), radius: 2, x: 0, y: -1)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    private var cardBackground: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .opacity(0.4)

            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .white.opacity(0.25),
                            .white.opacity(0.08),
                            .clear,
                            .black.opacity(0.05)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .white.opacity(0.6),
                            .white.opacity(0.2),
                            .white.opacity(0.05),
                            .white.opacity(0.3)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )

            RoundedRectangle(cornerRadius: 23)
                .strokeBorder(.white.opacity(0.1), lineWidth: 0.5)
        }
    }
}

