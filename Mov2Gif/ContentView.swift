//
//  ContentView.swift
//  Mov2Gif
//
//  Created by Carlos Felipe Araújo on 08/08/26.
//

import SwiftUI

/// The main view that orchestrates the conversion flow:
/// idle → video loaded → converting → done.
struct ContentView: View {
    @State private var viewModel = ConverterViewModel()

    var body: some View {
        ZStack {
            switch viewModel.state {
            case .idle:
                idleView

            case .videoLoaded:
                videoLoadedView

            case .converting:
                convertingView

            case .done:
                doneView

            case let .error(message):
                errorView(message: message)
            }
        }
        .frame(width: 440, height: 560)
        .animation(.easeInOut(duration: 0.3), value: viewModel.state)
    }

    // MARK: - Idle State

    private var idleView: some View {
        VStack(spacing: 0) {
            headerBar

            DropZoneView(
                onDrop: { providers in
                    viewModel.handleDrop(providers: providers)
                },
                onPickFile: {
                    viewModel.openFilePicker()
                }
            )
            .padding(20)
        }
    }

    // MARK: - Video Loaded State

    private var videoLoadedView: some View {
        VStack(spacing: 0) {
            headerBar

            ScrollView {
                VStack(spacing: 16) {
                    // Video preview card
                    videoPreviewCard

                    // Settings
                    SettingsPanel(settings: $viewModel.settings)

                    // Convert button
                    Button(action: {
                        viewModel.startConversion()
                    }) {
                        Label("Converter para GIF", systemImage: "wand.and.stars")
                            .font(.body)
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)

                    // Reset button
                    Button(action: {
                        viewModel.reset()
                    }) {
                        Text("Escolher outro vídeo")
                            .font(.subheadline)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
                }
                .padding(20)
            }
        }
    }

    // MARK: - Converting State

    private var convertingView: some View {
        VStack(spacing: 0) {
            headerBar

            Spacer()

            ProgressOverlay(
                progress: viewModel.progress,
                statusText: viewModel.statusText,
                onCancel: {
                    viewModel.cancelConversion()
                    viewModel.state = .videoLoaded
                }
            )

            Spacer()
        }
    }

    // MARK: - Done State

    private var doneView: some View {
        VStack(spacing: 0) {
            headerBar

            Spacer()

            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(.green)
                    .symbolEffect(.bounce, options: .nonRepeating)

                Text("GIF criado com sucesso!")
                    .font(.title3)
                    .fontWeight(.medium)

                Text(viewModel.videoFileName
                    .replacingOccurrences(of: ".mov", with: ".gif")
                    .replacingOccurrences(of: ".MOV", with: ".gif"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Button(action: {
                    viewModel.reset()
                }) {
                    Label("Converter outro vídeo", systemImage: "arrow.counterclockwise")
                        .font(.body)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding(.top, 8)
            }

            Spacer()
        }
    }

    // MARK: - Error State

    private func errorView(message: String) -> some View {
        VStack(spacing: 0) {
            headerBar

            Spacer()

            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.orange)

                Text("Erro na conversão")
                    .font(.title3)
                    .fontWeight(.medium)

                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Button(action: {
                    viewModel.state = .videoLoaded
                }) {
                    Text("Tentar novamente")
                        .font(.body)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding(.top, 8)

                Button(action: {
                    viewModel.reset()
                }) {
                    Text("Escolher outro vídeo")
                        .font(.subheadline)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }

    // MARK: - Shared Components

    private var headerBar: some View {
        HStack {
            Image(systemName: "film")
                .font(.title2)
                .foregroundStyle(Color.accentColor)

            Text("Mov2Gif")
                .font(.title2)
                .fontWeight(.bold)

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    private var videoPreviewCard: some View {
        VStack(spacing: 12) {
            // Thumbnail
            if let cgImage = viewModel.thumbnail {
                Image(decorative: cgImage, scale: 1.0)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            } else {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.secondary.opacity(0.1))
                    .frame(height: 120)
                    .overlay {
                        ProgressView()
                    }
            }

            // File info
            VStack(spacing: 4) {
                Text(viewModel.videoFileName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                    .truncationMode(.middle)

                HStack(spacing: 12) {
                    Label(viewModel.videoDuration, systemImage: "clock")
                    Label(viewModel.videoResolution, systemImage: "aspectratio")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.ultraThinMaterial)
        }
    }
}

#Preview {
    ContentView()
}
