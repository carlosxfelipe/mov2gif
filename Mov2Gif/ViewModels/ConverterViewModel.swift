//
//  ConverterViewModel.swift
//  Mov2Gif
//
//  Created by Carlos Felipe Araújo on 08/08/26.
//

import AVFoundation
import SwiftUI
import UniformTypeIdentifiers

/// The possible states of the converter.
enum ConverterState: Equatable {
    case idle
    case videoLoaded
    case converting
    case done
    case error(String)
}

/// ViewModel that manages the conversion state, user interactions, and orchestrates the pipeline.
@Observable
@MainActor
final class ConverterViewModel {
    // MARK: - Published State

    /// The current state of the converter.
    var state: ConverterState = .idle

    /// The URL of the loaded .mov file.
    var videoURL: URL?

    /// The display name of the loaded video.
    var videoFileName: String = ""

    /// A thumbnail preview of the loaded video.
    var thumbnail: CGImage?

    /// The video duration in a human-readable format.
    var videoDuration: String = ""

    /// The video resolution string (e.g., "1920×1080").
    var videoResolution: String = ""

    /// Conversion settings (FPS, scale, loop count).
    var settings = ConversionSettings()

    /// Conversion progress from 0.0 to 1.0.
    var progress: Double = 0.0

    /// Status text shown during conversion.
    var statusText: String = ""

    /// Whether conversion has been cancelled.
    private var isCancelled = false

    // MARK: - Video Loading

    /// Opens an NSOpenPanel for the user to select a .mov file.
    func openFilePicker() {
        let panel = NSOpenPanel()
        panel.title = "Selecionar Vídeo"
        panel.prompt = "Selecionar"
        panel.allowedContentTypes = [UTType.movie]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false

        guard panel.runModal() == .OK, let url = panel.url else { return }
        loadVideo(from: url)
    }

    /// Loads a video from a URL (from drag & drop or file picker).
    func loadVideo(from url: URL) {
        // Start accessing the security-scoped resource for sandboxed access
        let didStart = url.startAccessingSecurityScopedResource()

        videoURL = url
        videoFileName = url.lastPathComponent
        state = .videoLoaded
        progress = 0.0

        Task {
            // Generate thumbnail
            thumbnail = await GifConverter.generateThumbnail(for: url)

            // Get video metadata
            let asset = AVURLAsset(url: url)
            do {
                let duration = try await asset.load(.duration)
                let seconds = CMTimeGetSeconds(duration)
                let minutes = Int(seconds) / 60
                let secs = Int(seconds) % 60
                videoDuration = String(format: "%d:%02d", minutes, secs)

                if let track = try await asset.loadTracks(withMediaType: .video).first {
                    let size = try await track.load(.naturalSize)
                    videoResolution = "\(Int(size.width))×\(Int(size.height))"
                }
            } catch {
                videoDuration = "--:--"
                videoResolution = "—"
            }
        }
    }

    /// Handles a drop event. Returns `true` if a valid .mov was dropped.
    func handleDrop(providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first else { return false }

        provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { [weak self] item, _ in
            guard let data = item as? Data,
                  let url = URL(dataRepresentation: data, relativeTo: nil),
                  url.pathExtension.lowercased() == "mov"
            else {
                return
            }

            Task { @MainActor in
                self?.loadVideo(from: url)
            }
        }
        return true
    }

    // MARK: - Conversion

    /// Starts the conversion process.
    func startConversion() {
        guard let sourceURL = videoURL else { return }

        state = .converting
        progress = 0.0
        statusText = "Extraindo frames..."
        isCancelled = false

        Task {
            // Ask the user where to save via NSSavePanel
            let savePanel = NSSavePanel()
            savePanel.title = "Salvar GIF"
            savePanel.prompt = "Salvar"
            savePanel.allowedContentTypes = [UTType.gif]
            savePanel.nameFieldStringValue = videoFileName
                .replacingOccurrences(of: ".mov", with: ".gif")
                .replacingOccurrences(of: ".MOV", with: ".gif")

            guard savePanel.runModal() == .OK, let destinationURL = savePanel.url else {
                state = .videoLoaded
                return
            }

            do {
                try await GifConverter.convert(
                    sourceURL: sourceURL,
                    destinationURL: destinationURL,
                    settings: settings,
                    progressHandler: { [weak self] progressValue in
                        Task { @MainActor in
                            self?.progress = progressValue
                            if progressValue < 0.8 {
                                self?.statusText = "Extraindo frames..."
                            } else {
                                self?.statusText = "Gerando GIF..."
                            }
                        }
                    },
                    cancellationCheck: { [weak self] in
                        self?.isCancelled ?? false
                    }
                )

                state = .done
                statusText = "Conversão concluída!"
            } catch {
                state = .error(error.localizedDescription)
                statusText = "Erro: \(error.localizedDescription)"
            }
        }
    }

    /// Cancels the ongoing conversion.
    func cancelConversion() {
        isCancelled = true
    }

    /// Resets the state to allow a new conversion.
    func reset() {
        if let url = videoURL {
            url.stopAccessingSecurityScopedResource()
        }
        videoURL = nil
        videoFileName = ""
        thumbnail = nil
        videoDuration = ""
        videoResolution = ""
        progress = 0.0
        statusText = ""
        state = .idle
    }
}
