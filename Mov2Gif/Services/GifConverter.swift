//
//  GifConverter.swift
//  Mov2Gif
//
//  Created by Carlos Felipe Araújo on 08/08/26.
//

import AVFoundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

/// A 100% native .mov → .gif converter using AVFoundation + ImageIO.
/// No external dependencies (no FFmpeg).
enum GifConverter {
    /// Errors that can occur during conversion.
    enum ConversionError: LocalizedError {
        case cannotLoadAsset
        case cannotReadVideoTrack
        case cannotCreateImageDestination
        case frameExtractionFailed
        case noFramesExtracted
        case cancelled

        var errorDescription: String? {
            switch self {
            case .cannotLoadAsset:
                return String(localized: "Could not load the video.")
            case .cannotReadVideoTrack:
                return String(localized: "Could not read the video track from the file.")
            case .cannotCreateImageDestination:
                return String(localized: "Could not create the destination GIF file.")
            case .frameExtractionFailed:
                return String(localized: "Failed to extract frames from the video.")
            case .noFramesExtracted:
                return String(localized: "No frames were extracted from the video.")
            case .cancelled:
                return String(localized: "Conversion cancelled.")
            }
        }
    }

    /// Converts a .mov file at `sourceURL` to a .gif file at `destinationURL`.
    ///
    /// - Parameters:
    ///   - sourceURL: The URL of the .mov video file.
    ///   - destinationURL: The URL where the .gif will be saved.
    ///   - settings: The conversion settings (FPS, scale, loop count).
    ///   - progressHandler: Called on the main actor with a value from 0.0 to 1.0.
    ///   - cancellationCheck: Called periodically; return `true` to cancel.
    static func convert(
        sourceURL: URL,
        destinationURL: URL,
        settings: ConversionSettings,
        progressHandler: @Sendable @escaping (Double) -> Void,
        cancellationCheck: @Sendable @escaping () -> Bool = { false }
    ) async throws {
        // 1. Load the asset and get the video track
        let asset = AVURLAsset(url: sourceURL)

        let duration: CMTime
        let videoTrack: AVAssetTrack

        do {
            duration = try await asset.load(.duration)
            guard let track = try await asset.loadTracks(withMediaType: .video).first else {
                throw ConversionError.cannotReadVideoTrack
            }
            videoTrack = track
        } catch is ConversionError {
            throw ConversionError.cannotReadVideoTrack
        } catch {
            throw ConversionError.cannotLoadAsset
        }

        // 2. Calculate the natural size and apply scale
        let naturalSize: CGSize
        do {
            naturalSize = try await videoTrack.load(.naturalSize)
        } catch {
            throw ConversionError.cannotReadVideoTrack
        }

        let scaledWidth = Int(naturalSize.width * settings.scale)
        let scaledHeight = Int(naturalSize.height * settings.scale)

        // 3. Calculate the times at which to extract frames
        let totalSeconds = CMTimeGetSeconds(duration)
        let frameInterval = 1.0 / Double(settings.fps)
        var frameTimes: [CMTime] = []
        var currentTime: Double = 0

        while currentTime < totalSeconds {
            frameTimes.append(CMTime(seconds: currentTime, preferredTimescale: 600))
            currentTime += frameInterval
        }

        guard !frameTimes.isEmpty else {
            throw ConversionError.noFramesExtracted
        }

        // 4. Configure the image generator
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.maximumSize = CGSize(width: scaledWidth, height: scaledHeight)
        imageGenerator.requestedTimeToleranceBefore = CMTime(seconds: frameInterval / 2, preferredTimescale: 600)
        imageGenerator.requestedTimeToleranceAfter = CMTime(seconds: frameInterval / 2, preferredTimescale: 600)

        // 5. Extract frames
        var extractedFrames: [(index: Int, image: CGImage)] = []
        let totalFrames = frameTimes.count

        // Extract frames one by one using the async API
        for (frameIndex, time) in frameTimes.enumerated() {
            if cancellationCheck() {
                throw ConversionError.cancelled
            }

            do {
                let (image, _) = try await imageGenerator.image(at: time)
                extractedFrames.append((index: frameIndex, image: image))
            } catch {
                // Skip frames that fail to extract
            }

            let progress = Double(frameIndex + 1) / Double(totalFrames) * 0.8 // 80% for frame extraction
            progressHandler(progress)
        }

        guard !extractedFrames.isEmpty else {
            throw ConversionError.noFramesExtracted
        }

        // Sort by index to maintain order
        extractedFrames.sort { $0.index < $1.index }

        if cancellationCheck() {
            throw ConversionError.cancelled
        }

        // 6. Create the GIF using ImageIO
        try writeGif(
            frames: extractedFrames.map { $0.image },
            to: destinationURL,
            settings: settings,
            progressHandler: { gifProgress in
                // Map the last 20% of progress to GIF writing
                progressHandler(0.8 + gifProgress * 0.2)
            }
        )

        progressHandler(1.0)
    }

    /// Writes an array of CGImage frames to a GIF file.
    private static func writeGif(
        frames: [CGImage],
        to url: URL,
        settings: ConversionSettings,
        progressHandler: @escaping (Double) -> Void
    ) throws {
        // GIF file properties
        let gifProperties: [String: Any] = [
            kCGImagePropertyGIFDictionary as String: [
                kCGImagePropertyGIFLoopCount as String: settings.loopCount,
            ],
        ]

        // Per-frame properties
        let frameProperties: [String: Any] = [
            kCGImagePropertyGIFDictionary as String: [
                kCGImagePropertyGIFDelayTime as String: settings.frameDelay,
                kCGImagePropertyGIFUnclampedDelayTime as String: settings.frameDelay,
            ],
        ]

        guard let destination = CGImageDestinationCreateWithURL(
            url as CFURL,
            UTType.gif.identifier as CFString,
            frames.count,
            nil
        ) else {
            throw ConversionError.cannotCreateImageDestination
        }

        CGImageDestinationSetProperties(destination, gifProperties as CFDictionary)

        for (index, frame) in frames.enumerated() {
            CGImageDestinationAddImage(destination, frame, frameProperties as CFDictionary)
            let progress = Double(index + 1) / Double(frames.count)
            progressHandler(progress)
        }

        if !CGImageDestinationFinalize(destination) {
            throw ConversionError.cannotCreateImageDestination
        }
    }

    /// Generates a thumbnail image from a video at the given URL.
    static func generateThumbnail(for url: URL) async -> CGImage? {
        let asset = AVURLAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.maximumSize = CGSize(width: 400, height: 400)

        do {
            let (image, _) = try await imageGenerator.image(at: .zero)
            return image
        } catch {
            return nil
        }
    }
}
