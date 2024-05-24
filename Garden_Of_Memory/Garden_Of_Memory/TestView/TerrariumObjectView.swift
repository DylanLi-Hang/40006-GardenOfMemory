//
//  TerrariumObjectView.swift
//  Garden_Of_Memory
//
//  Created by Yu Ching Wong on 22/4/2024.
//


import SwiftUI
import SwiftData
import RealityKit
import RealityKitContent

struct TerrariumObjectView: View {
    @Environment(\.openImmersiveSpace) var openImmersiveTerrarium
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveTerrarium

    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow

    @State private var isTerraObjViewOpen: Bool = true
    let viewModel = ViewModel.shared
    @State private var currentScene: Entity? = nil
    @State private var currentMood: Int = 0 // Track mood to trigger updates
    @State private var sceneName: String = "TerrariumSunnyScene" // Default scene
    @State private var sceneVersion: Int = 0 // Force scene update

    var body: some View {
        VStack {
            RealityView { content in
                if let scene = currentScene {
                    content.add(scene)
                    print("RealityView: Added scene \(scene.name)")
                }
            }
            .id(sceneVersion) // This forces the RealityView to reload
            .gesture(TapGesture()
                .targetedToAnyEntity()
                .onEnded({ value in
                    print("OpenTerrarium tapped")
                    Task {
                        await openImmersiveTerrarium(id: "FullTerrarium")
                        dismissWindow(id: "terrariumObject")
                        isTerraObjViewOpen = false
                        viewModel.terrarium = true
                        print("Opened immersive terrarium and dismissed window")
                    }
                })
            )
        }
        .onAppear {
            // Initialize the scene when the view appears
            currentMood = viewModel.mood
            sceneName = terrariumSceneName(for: currentMood)
            print("onAppear: Initial mood is \(currentMood), loading scene \(sceneName)")
            Task {
                await loadScene(named: sceneName)
                sceneVersion += 1 // Force RealityView to reload
            }
        }
        .onChange(of: viewModel.mood) { oldMood, newMood in
            // Trigger the update of the RealityView when the mood changes
            currentMood = newMood
            sceneName = terrariumSceneName(for: currentMood)
            print("onChange: Mood changed to \(newMood), loading scene \(sceneName)")
            Task {
                await loadScene(named: sceneName)
                sceneVersion += 1 // Force RealityView to reload
            }
        }
    }

    private func terrariumSceneName(for mood: Int) -> String {
        // Return the appropriate scene name based on mood
        switch mood {
        case 1:
            return "TerrariumThunderScene"
        case 2:
            return "TerrariumRainScene"
        case 3:
            return "TerrariumCloudScene"
        case 4:
            return "TerrariumSunnyScene"
        case 5:
            return "TerrariumRainbowScene"
        default:
            return "TerrariumSunnyScene" // Default scene
        }
    }

    private func loadScene(named sceneName: String) async {
        print("!! loadScene called !!")
        print("Loading scene: \(sceneName) for mood: \(currentMood)")
        if let scene = try? await Entity(named: sceneName, in: realityKitContentBundle) {
            print("Scene \(sceneName) loaded successfully with entity name: \(await scene.name)")
            DispatchQueue.main.async {
                if let oldScene = currentScene {
                    print("Removing old scene: \(oldScene.name)")
                    currentScene = nil
                }
                currentScene = scene
                print("Added new scene: \(scene.name) for mood: \(currentMood)")
                
                guard let resource = try? AudioFileResource.load(named: "/Root/Sunny_mp3",
                                                                 from: "TerrariumSunnyScene.usda",
                                                                 in: RealityKitContent.realityKitContentBundle) else {
                    print("Failed to load audio resource")
                    return
                }
                let audioPlaybackController = scene.prepareAudio(resource)
                audioPlaybackController.play()
                print("Playing audio for scene: \(scene.name)")
            }
        } else {
            print("Failed to load scene: \(sceneName) for mood: \(currentMood)")
        }
    }
}
