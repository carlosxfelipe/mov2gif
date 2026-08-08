//
//  Mov2GifApp.swift
//  Mov2Gif
//
//  Created by Carlos Felipe Araújo on 08/08/26.
//

import SwiftUI

@main
struct Mov2GifApp: App {
    @State private var languageManager = LanguageManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 440, height: 560)
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About Mov2Gif") {
                    if let aboutWindow = NSApplication.shared.windows.first(where: {
                        $0.identifier?.rawValue == "about"
                    }) {
                        aboutWindow.makeKeyAndOrderFront(nil)
                    } else {
                        let controller = NSHostingController(rootView: AboutView())
                        let window = NSWindow(contentViewController: controller)
                        window.identifier = NSUserInterfaceItemIdentifier("about")
                        window.title = String(localized: "About Mov2Gif")
                        window.styleMask = [.titled, .closable]
                        window.center()
                        window.makeKeyAndOrderFront(nil)
                    }
                }
            }

            CommandMenu(String(localized: "Language")) {
                Button("🌐  " + String(localized: "System Default")) {
                    languageManager.setLanguage(nil)
                }
                .keyboardShortcut(.none)

                Divider()

                Button("🇺🇸  English") {
                    languageManager.setLanguage("en")
                }
                .keyboardShortcut(.none)

                Button("🇧🇷  Português") {
                    languageManager.setLanguage("pt-BR")
                }
                .keyboardShortcut(.none)
            }
        }
    }
}
