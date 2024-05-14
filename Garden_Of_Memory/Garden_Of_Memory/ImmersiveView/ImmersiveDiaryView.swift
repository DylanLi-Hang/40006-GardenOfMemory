//
//  DiaryView.swift
//  Garden_Of_Memory
//
//  Created by Denni O on 4/23/24.
//

import SwiftUI
import SwiftData
import RealityKit
import RealityKitContent
import AVFoundation

struct ImmersiveDiaryView: View {
    var body: some View {
        RealityView { content in
            // Add the initial RealityKit content
            if let scene = try? await Entity(named: "Diary", in: realityKitContentBundle) {
                content.add(scene)
            }
        } update: { content in
           
        }
        .onAppear() {
            AudioPlayer.playAudio()
        }
    }
}

struct AudioPlayer {
    static func playAudio() {
        guard let url = Bundle.main.url(forResource: "DiarySoundEffect", withExtension: "mp3") else {
            print("Audio file not found.")
            return
        }
        let player = AVPlayer(url: url)
        player.play()
    }
}

#Preview {
    ImmersiveDiaryView()
}
