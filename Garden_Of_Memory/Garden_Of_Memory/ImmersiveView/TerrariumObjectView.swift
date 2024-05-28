////
////  TerrariumObjectView.swift
////  Garden_Of_Memory
////
////  Created by Yu Ching Wong on 22/4/2024.
////
//
//import SwiftUI
//import SwiftData
//import RealityKit
//import RealityKitContent
//
//struct TerrariumObjectView: View {
//    @Environment(\.openImmersiveSpace) var openImmersiveTerrarium
//    @Environment(\.dismissImmersiveSpace) var dismissImmersiveTerrarium
//
//    @Environment(\.openWindow) private var openWindow
//    @Environment(\.dismissWindow) private var dismissWindow
//
//    @State private var isTerraObjViewOpen: Bool = true
//    let viewModel = ViewModel.shared
//    @State private var currentScene: Entity? = nil
//    @State private var currentMood: Int = 0 // Track mood to trigger updates
//    @State private var sceneName: String = "TerrariumSunnyScene" // Default scene
//    @State private var sceneVersion: Int = 0 // Force scene update
//
//    var body: some View {
//        VStack {
//            RealityView { content in
//                if let scene = currentScene {
//                    content.add(scene)
//                    print("RealityView: Added scene \(scene.name)")
//                }
//            }
//            .id(sceneVersion) // This forces the RealityView to reload
//            .gesture(TapGesture()
//                .targetedToAnyEntity()
//                .onEnded({ value in
//                    print("OpenTerrarium tapped")
//                    Task {
//                        await openImmersiveTerrarium(id: "FullTerrarium")
//                        dismissWindow(id: "terrariumObject")
//                        isTerraObjViewOpen = false
//                        viewModel.terrarium = true
//                        print("Opened immersive terrarium and dismissed window")
//                    }
//                })
//            )
//        }
//        .onAppear {
//            // Initialize the scene when the view appears
//            currentMood = viewModel.mood
//            sceneName = terrariumSceneName(for: currentMood)
//            print("onAppear: Initial mood is \(currentMood), loading scene \(sceneName)")
//            Task {
//                await loadScene(named: sceneName)
//                sceneVersion += 1 // Force RealityView to reload
//            }
//        }
//        .onChange(of: viewModel.mood) { oldMood, newMood in
//            // Trigger the update of the RealityView when the mood changes
//            currentMood = newMood
//            sceneName = terrariumSceneName(for: currentMood)
//            print("onChange: Mood changed to \(newMood), loading scene \(sceneName)")
//            Task {
//                await loadScene(named: sceneName)
//                sceneVersion += 1 // Force RealityView to reload
//            }
//        }
//    }
//
//    private func terrariumSceneName(for mood: Int) -> String {
//        // Return the appropriate scene name based on mood
//        switch mood {
//        case 1:
//            return "TerrariumThunderScene"
//        case 2:
//            return "TerrariumRainScene"
//        case 3:
//            return "TerrariumCloudScene"
//        case 4:
//            return "TerrariumSunnyScene"
//        case 5:
//            return "TerrariumRainbowScene"
//        default:
//            return "TerrariumSunnyScene" // Default scene
//        }
//    }
//
//    private func loadScene(named sceneName: String) async {
//        print("!! loadScene called !!")
//        print("Loading scene: \(sceneName) for mood: \(currentMood)")
//        if let scene = try? await Entity(named: sceneName, in: realityKitContentBundle) {
//            print("Scene \(sceneName) loaded successfully with entity name: \(await scene.name)")
//            DispatchQueue.main.async {
//                if let oldScene = currentScene {
//                    print("Removing old scene: \(oldScene.name)")
//                    currentScene = nil
//                }
//                currentScene = scene
//                print("Added new scene: \(scene.name) for mood: \(currentMood)")
//                
//                loadAndPlayAudio(for: sceneName, in: scene)
//            }
//        } else {
//            print("Failed to load scene: \(sceneName) for mood: \(currentMood)")
//        }
//    }
//
//    private func loadAndPlayAudio(for sceneName: String, in scene: Entity) {
//        let audioFileName: String
//        switch sceneName {
//        case "TerrariumThunderScene":
//            audioFileName = "Thunder.mp3"
//        case "TerrariumRainScene":
//            audioFileName = "Rain.mp3"
//        case "TerrariumCloudScene":
//            audioFileName = "Cloud.mp3"
//        case "TerrariumSunnyScene":
//            audioFileName = "Sunny.mp3"
//        case "TerrariumRainbowScene":
//            audioFileName = "Rainbow.mp3"
//        default:
//            audioFileName = "Sunny.mp3"
//        }
//
//        print("Attempting to load audio resource named: \(audioFileName)")
//        
//        let bundle = Bundle.main
//        
//        guard let resourceURL = bundle.url(forResource: audioFileName, withExtension: nil) else {
//            print("Failed to find URL for resource \(audioFileName) in \(bundle.bundlePath)")
//            
//            // Print bundle path and its contents for debugging
//            print("Bundle path: \(bundle.bundlePath)")
//            if let resourcePath = bundle.resourcePath {
//                print("Bundle resource path: \(resourcePath)")
//                do {
//                    let files = try FileManager.default.contentsOfDirectory(atPath: resourcePath)
//                    print("Files in resource path: \(files)")
//                } catch {
//                    print("Error listing files in resource path: \(error)")
//                }
//            }
//            
//            return
//        }
//        
//        print("Resource URL for \(audioFileName): \(resourceURL)")
//        
//        guard let resource = try? AudioFileResource.load(contentsOf: resourceURL) else {
//            print("Failed to load audio resource from \(resourceURL).")
//            return
//        }
//        
//        print("Audio resource \(audioFileName) loaded successfully from \(resourceURL)")
//        let audioPlaybackController = scene.prepareAudio(resource)
//        audioPlaybackController.play()
//        print("Playing audio \(audioFileName) for scene: \(scene.name)")
//    }
//}





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
                    scene.position += [0, -0.4, 0.2]
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
                
                playAudioForScene(sceneName: sceneName)
            }
        } else {
            print("Failed to load scene: \(sceneName) for mood: \(currentMood)")
        }
    }

    private func playAudioForScene(sceneName: String) {
        let audioFileName: String
        switch sceneName {
        case "TerrariumThunderScene":
            audioFileName = "Thunder.mp3"
        case "TerrariumRainScene":
            audioFileName = "Rain.mp3"
        case "TerrariumCloudScene":
            audioFileName = "Cloud.mp3"
        case "TerrariumSunnyScene":
            audioFileName = "Sunny.mp3"
        case "TerrariumRainbowScene":
            audioFileName = "Rainbow.mp3"
        default:
            audioFileName = "Sunny.mp3"
        }

        print("Attempting to play audio named: \(audioFileName)")
        AudioManager.shared.playAudio(named: audioFileName)
    }
}
