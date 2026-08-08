//
//  ConversionSettings.swift
//  Mov2Gif
//
//  Created by Carlos Felipe Araújo on 08/08/26.
//

import Foundation

/// Settings that control how a .mov video is converted into a .gif.
struct ConversionSettings {
    /// Frames per second for the output GIF (range: 5–30).
    var fps: Int = 10

    /// Scale factor applied to the video dimensions (range: 0.25–1.0).
    /// For example, 0.5 means the GIF will be half the original resolution.
    var scale: Double = 0.5

    /// Number of times the GIF loops. 0 means infinite loop.
    var loopCount: Int = 0

    /// The delay between each frame in seconds, derived from FPS.
    var frameDelay: Double {
        1.0 / Double(fps)
    }
}
