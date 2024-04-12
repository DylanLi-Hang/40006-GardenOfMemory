//
//  CatImmersiveView.swift
//  MyFirstImmersive
//
//  Created by Dylan on 9/4/2024.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct CatImmersiveView: View {
    
    private static let planeX: Float = 3.75
    private static let planeZ: Float = 2.625
    
    @State var planeEntity: Entity = {
        let wallAnchor = AnchorEntity(.plane(.vertical, classification: .wall, minimumBounds: SIMD2<Float>(0.6, 0.6)))
        let planeMesh = MeshResource.generatePlane(width: Self.planeX, depth: Self.planeZ, cornerRadius: 0.1)
        let planeEntity = ModelEntity(mesh: planeMesh, materials: [SimpleMaterial()])
        planeEntity.name = "canvas"
        wallAnchor.addChild(planeEntity)
        return wallAnchor
    }()
    
    @State var floorEntity: Entity = {
        let floorAnchor = AnchorEntity(.plane(.horizontal, classification: .table, minimumBounds: SIMD2<Float>(0.3, 0.3)))
//        let planeMesh = MeshResource.generatePlane(width: 0.5, depth: 0.5, cornerRadius: 0.1)
//        let planeEntity = ModelEntity(mesh: planeMesh, materials: [SimpleMaterial()])
//        planeEntity.name = "table"
//        floorAnchor.addChild(planeEntity)
        return floorAnchor
    }()
    
    @State var groundEntity: Entity = {
        let groundAnchor = AnchorEntity(.plane(.vertical, classification: .floor, minimumBounds: SIMD2<Float>(0.6, 0.6)))
        let planeMesh = MeshResource.generatePlane(width: 1, depth: 1, cornerRadius: 0.1)
        let planeEntity = ModelEntity(mesh: planeMesh, materials: [SimpleMaterial()])
        planeEntity.name = "cat"
        groundAnchor.addChild(planeEntity)
        return groundAnchor
    }()
    
    var body: some View {
        RealityView { content, attachments in
            // Add the initial RealityKit content
            do {
                let scene = try await Entity(named: "CatScene", in: realityKitContentBundle)
//                let groundAnchor = AnchorEntity(.plane(.any, classification: .floor, minimumBounds: SIMD2<Float>(0.6, 0.6)))
//                groundAnchor.addChild(scene)
//                content.add(groundAnchor)
                floorEntity.addChild(scene)
                content.add(planeEntity)
                content.add(floorEntity)
//                content.add(groundEntity)
//                content.add(scene)
                
                setupCat(rootEntity: scene)
                
                if let sceneAttachment = attachments.entity(for: "caption") {
                    guard let cat = scene.findEntity(named: "Toon_Cat_FREE") else { return }
                    sceneAttachment.position = cat.position
                    sceneAttachment.position += SIMD3(0, 1.5, 0)
//                    sceneAttachment.transform.rotation = simd_quatf(angle: -0.5, axis: SIMD3<Float>(1,0,0))
                    content.add(sceneAttachment)
                }
            } catch {
                print("Error in RealityView's make: \(error)")
            }
        } update: { content, _ in
            // Update the RealityKit content when SwiftUI state changes
        } attachments: {
            Attachment(id: "caption") {
                Text("I'm a moving Cattttt!")
                    .frame(maxWidth: 600, alignment: .leading)
                    .font(.extraLargeTitle2)
                    .fontWeight(.regular)
                    .padding(40)
                    .glassBackgroundEffect()
            }
        }
        .gesture(TapGesture().targetedToAnyEntity().onEnded { value in
            print("Tapped CatView")
            var transform = value.entity.transform
            transform.translation += SIMD3(0.1, 0, -0.1)
            value.entity.move(
                to: transform,
                relativeTo: nil,
                duration: 3,
                timingFunction: .easeInOut
            )
        })
    }
    private func setupCat(rootEntity entity: Entity) {
        //Root/Toon_Cat_FREE/SkinnedMeshes/Sketchfab_model/_df7f1c552db41979cdb0b8efba99edf_fbx/Object_2/RootNode/Rig/Object_5/_rootJoint/root_01/skin0
        guard let cat = entity.findEntity(named: "root_01") else { return }
        print(cat.name)
        print(cat.availableAnimations)
        guard let animationResource = cat.availableAnimations.first else {return}
        print("cat animation loaded")
        let controller = cat.playAnimation(animationResource.repeat())
        controller.speed = Float.random(in: 1..<2.5)
    }
}

#Preview {
    CatImmersiveView()
}
