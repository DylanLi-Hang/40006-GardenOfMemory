//
//  DiaryView.swift
//  Garden_Of_Memory
//
//  Created by Denni O on 4/23/24.
//
import SwiftUI
import RealityKit
import RealityKitContent
import AVFoundation

struct ImmersiveDiaryView: View {
    @State private var navigateToGrid = false

    var body: some View {
        NavigationStack {
            ZStack {
                RealityView { content in
                    // Add the initial RealityKit content
                    if let scene = try? await Entity(named: "Diary", in: realityKitContentBundle) {
                        content.add(scene)
                        scene.generateCollisionShapes(recursive: true)
                    }
                } update: { content in

                }
                .onAppear {
                    AudioPlayer.playAudio()
                }
                .onTapGesture {
                    // Handle tap gesture to navigate
                    navigateToGrid = true
                }

                NavigationLink(destination: TerrariumGridView(), isActive: $navigateToGrid) {
                    EmptyView()
                }
            }
            .navigationTitle("Immersive Diary")
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

struct ImmersiveDiaryView_Previews: PreviewProvider {
    static var previews: some View {
        ImmersiveDiaryView()
    }
}

