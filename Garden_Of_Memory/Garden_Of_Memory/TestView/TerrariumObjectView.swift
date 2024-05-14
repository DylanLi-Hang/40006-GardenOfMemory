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
    
    // @ObservedObject var emotionScaleViewModel: EmotionScaleViewModel // Observes changes in mood
    
    let viewModel = ViewModel.shared
    
    var body: some View {
        
        RealityView { content in
//            // Add the initial RealityKit content
//            if let scene = try? await Entity(named: "TerrariumSunnyScene", in: realityKitContentBundle) {
//                content.add(scene)
////                guard let thunder = scene.findEntity(named: "/Root/ThunderEmitter"),
////                      let resource = try? AudioFileResource(named: "/Root/Thunder_wav", from: "TerrariumThunderScene.usda", in: RealityKitContent.realityKitContentBundle) else { return }
//                print("prepare play audio")
//                guard let resource = try? AudioFileResource.load(named: "/Root/Sunny_mp3",
//                                                                 from: "TerrariumSunnyScene.usda",
//                                                                 in: RealityKitContent.realityKitContentBundle) else { return }
//                let audioPlaybackController = scene.prepareAudio(resource)
//                audioPlaybackController.play()
//                print("play audio")
//            }
            
            
            
            // Add the initial RealityKit content
            if let scene = try? await Entity(named: terrariumSceneName(for: viewModel.mood), in: realityKitContentBundle) {
                content.add(scene)
            }
        } update: { content in
            
            // Update the RealityKit content when SwiftUI state changes
//            if let scene = content.entities.first {
//                let uniformScale: Float = enlarge ? 1.4 : 1.0
//                scene.transform.scale = [uniformScale, uniformScale, uniformScale]
//            }
        }
        .onAppear() {
        }
        
        .gesture(TapGesture()
            .targetedToAnyEntity()
            .onEnded({ value in
                print("OpenTerrarium")
                Task{
                    await openImmersiveTerrarium(id:"FullTerrarium")
                    dismissWindow(id: "terrariumObject")
                    isTerraObjViewOpen = false
                    ImmersiveTerrariumState.terrarium = true
                }
            })
        )
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
}

//#Preview {
//    TerrariumObjectView()
//}
