//
//  LanguageManager.swift
//  Mov2Gif
//
//  Created by Carlos Felipe Araújo on 08/08/26.
//

import AppKit
import Foundation

/// Manages the app language preference and handles relaunching to apply changes.
@Observable
@MainActor
final class LanguageManager {
    /// The currently active language code, or nil for system default.
    var currentLanguage: String? {
        UserDefaults.standard.stringArray(forKey: "AppleLanguages")?.first
    }

    /// Whether the current language is the system default.
    var isSystemDefault: Bool {
        // If we haven't overridden, it's system default
        !UserDefaults.standard.bool(forKey: "languageOverridden")
    }

    /// Changes the app language and relaunches to apply.
    func setLanguage(_ languageCode: String?) {
        if let languageCode {
            UserDefaults.standard.set([languageCode], forKey: "AppleLanguages")
            UserDefaults.standard.set(true, forKey: "languageOverridden")
        } else {
            // Reset to system default
            UserDefaults.standard.removeObject(forKey: "AppleLanguages")
            UserDefaults.standard.set(false, forKey: "languageOverridden")
        }
        UserDefaults.standard.synchronize()
        relaunchApp()
    }

    /// Relaunches the app to apply the language change.
    private func relaunchApp() {
        let url = URL(fileURLWithPath: Bundle.main.resourcePath!)
        let path = url.deletingLastPathComponent().deletingLastPathComponent().absoluteString
        let task = Process()
        task.launchPath = "/usr/bin/open"
        task.arguments = [path, "--args", "--relaunch"]
        task.launch()
        NSApplication.shared.terminate(nil)
    }
}
