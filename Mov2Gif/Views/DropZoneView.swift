//
//  DropZoneView.swift
//  Mov2Gif
//
//  Created by Carlos Felipe Araújo on 08/08/26.
//

import SwiftUI
import UniformTypeIdentifiers

/// A stylized drag-and-drop zone that accepts .mov files.
struct DropZoneView: View {
    let onDrop: ([NSItemProvider]) -> Bool
    let onPickFile: () -> Void

    @State private var isTargeted = false

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "arrow.down.doc")
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(isTargeted ? Color.accentColor : .secondary)
                .symbolEffect(.pulse, options: .repeating, isActive: isTargeted)

            Text("Arraste um vídeo .mov aqui")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundStyle(isTargeted ? Color.accentColor : .primary)

            Text("ou")
                .font(.caption)
                .foregroundStyle(.tertiary)

            Button(action: onPickFile) {
                Label("Selecionar Arquivo", systemImage: "folder")
                    .font(.body)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(
                    isTargeted ? Color.accentColor : Color.secondary.opacity(0.3),
                    style: StrokeStyle(lineWidth: 2, dash: [8, 4])
                )
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(isTargeted ? Color.accentColor.opacity(0.05) : Color.clear)
                )
        }
        .onDrop(of: [UTType.fileURL], isTargeted: $isTargeted) { providers in
            onDrop(providers)
        }
        .animation(.easeInOut(duration: 0.2), value: isTargeted)
    }
}
