//
//  ProgressOverlay.swift
//  Mov2Gif
//
//  Created by Carlos Felipe Araújo on 08/08/26.
//

import SwiftUI

/// An overlay showing the conversion progress with a circular indicator and status text.
struct ProgressOverlay: View {
    let progress: Double
    let statusText: String
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                // Background ring
                Circle()
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 6)
                    .frame(width: 80, height: 80)

                // Progress ring
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        Color.accentColor,
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.3), value: progress)

                // Percentage
                Text("\(Int(progress * 100))%")
                    .font(.title3.monospacedDigit())
                    .fontWeight(.semibold)
                    .contentTransition(.numericText())
                    .animation(.default, value: Int(progress * 100))
            }

            Text(statusText)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button(action: onCancel) {
                Text("Cancel")
                    .font(.subheadline)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
        }
        .padding(32)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
        }
    }
}
