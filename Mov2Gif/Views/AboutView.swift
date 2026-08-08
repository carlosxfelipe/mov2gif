//
//  AboutView.swift
//  Mov2Gif
//
//  Created by Carlos Felipe Araújo on 08/08/26.
//

import SwiftUI

/// The About window content showing app info, author, and GitHub link.
struct AboutView: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "film")
                .font(.system(size: 48))
                .foregroundStyle(Color.accentColor)

            Text("Mov2Gif")
                .font(.title)
                .fontWeight(.bold)

            Text("Version 1.0")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Divider()
                .padding(.horizontal, 40)

            VStack(spacing: 6) {
                Text("Developed by")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("Carlos Felipe Araújo")
                    .font(.headline)
            }

            Button(action: {
                if let url = URL(string: "https://github.com/carlosxfelipe") {
                    openURL(url)
                }
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "link")
                    Text("github.com/carlosxfelipe")
                }
                .font(.subheadline)
            }
            .buttonStyle(.plain)
            .foregroundStyle(Color.accentColor)
        }
        .padding(32)
        .frame(width: 300, height: 320)
    }
}

#Preview {
    AboutView()
}
