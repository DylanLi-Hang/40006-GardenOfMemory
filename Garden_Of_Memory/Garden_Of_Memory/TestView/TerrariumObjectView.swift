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
    
    var body: some View {
        
        RealityView { content in
            // Add the initial RealityKit content
            if let scene = try? await Entity(named: "TerrariumThunderScene", in: realityKitContentBundle) {
                content.add(scene)
//                guard let thunder = scene.findEntity(named: "/Root/ThunderEmitter"),
//                      let resource = try? AudioFileResource(named: "/Root/Thunder_wav", from: "TerrariumThunderScene.usda", in: RealityKitContent.realityKitContentBundle) else { return }
                print("prepare play audio")
                guard let resource = try? AudioFileResource.load(named: "/Root/Thunder_wav",
                                                                 from: "TerrariumThunderScene.usda",
                                                                 in: RealityKitContent.realityKitContentBundle) else { return }
                let audioPlaybackController = scene.prepareAudio(resource)
                audioPlaybackController.play()
                print("play audio")
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
        
//        .gesture(TapGesture()
//            .targetedToAnyEntity()
//            .onEnded({ value in
//                print("Tapped work \(value.entity)")
//                
//            })
//        )
    }
}

#Preview {
    TerrariumObjectView()
}
