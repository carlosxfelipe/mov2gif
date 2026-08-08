//
//  SettingsPanel.swift
//  Mov2Gif
//
//  Created by Carlos Felipe Araújo on 08/08/26.
//

import SwiftUI

/// A panel with sliders and controls for adjusting GIF conversion settings.
struct SettingsPanel: View {
    @Binding var settings: ConversionSettings

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Settings")
                .font(.headline)
                .foregroundStyle(.primary)

            // FPS Slider
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("FPS")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(settings.fps)")
                        .font(.subheadline.monospacedDigit())
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                }
                Slider(
                    value: Binding(
                        get: { Double(settings.fps) },
                        set: { settings.fps = Int($0) }
                    ),
                    in: 5 ... 30,
                    step: 1
                )
            }

            Divider()

            // Scale Slider
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Scale")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(Int(settings.scale * 100))%")
                        .font(.subheadline.monospacedDigit())
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                }
                Slider(
                    value: $settings.scale,
                    in: 0.25 ... 1.0,
                    step: 0.05
                )
            }

            Divider()

            // Loop Toggle
            HStack {
                Text("Infinite Loop")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Toggle("", isOn: Binding(
                    get: { settings.loopCount == 0 },
                    set: { settings.loopCount = $0 ? 0 : 1 }
                ))
                .toggleStyle(.switch)
                .labelsHidden()
            }
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.ultraThinMaterial)
        }
    }
}
