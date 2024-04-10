//
//  WaterView.swift
//  Garden_Of_Memory
//
//  Created by Yu Ching Wong on 9/4/2024.
//

//import SwiftUI
//import RealityKit
//import RealityKitContent
//
//struct WaterView: View {
//    @State public var upAnimation = false
//    @State public var downAnimation = true
//    @State var particles = ParticleEmitterComponent()
//    
//    @StateObject var speechRecognizer = SpeechRecognizer()
//    
//    let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
//    @State private var count:Int = 1
//
//    @State private var waterDrop: Entity? = nil
//    @State var characterEntity: Entity = {
//        let headAnchor = AnchorEntity(.head)
//        headAnchor.position = [0.70, -0.35, -1]
//        let radians = -30 * Float.pi / 180
//        WaterView.rotateEntityAroundYAxis(entity: headAnchor, angle: radians)
//        return headAnchor
//    }()
//    
//    var body: some View {
//        RealityView { content in
//            // Add the initial RealityKit content
//            do {
//                let immersiveEntity = try await Entity(named: "Immersive", in: realityKitContentBundle)
//                characterEntity.addChild(immersiveEntity)
//                content.add(characterEntity)
//            } catch {
//                print("Error in RealityView's make: \(error)")
//            }
//        }
//        .gesture(TapGesture()
//            .targetedToAnyEntity()
//            .onEnded({ value in print("Tapped work \(value.entity)")
//                if !upAnimation{
//                    //move the water drop upward after tap gesture
//                    particles.isEmitting = false
//                    value.entity.components.remove(ParticleEmitterComponent.self)
//                    value.entity.components[ParticleEmitterComponent.self] = pSystem()
//                    var transform = value.entity.transform
//                    transform.translation += SIMD3(0.70, -0.15, -1)
//                    let radians = -30 * Float.pi / 180
//                    transform.rotation = simd_quatf(angle: radians, axis: SIMD3<Float>(0,1,0))
//                    value.entity.move(to: transform, relativeTo: nil, duration: 1, timingFunction: .easeInOut)
//                    if(transform.translation.y > 0.3){
//                        upAnimation = true
//                        downAnimation = false
//                    }
//                    print("first")
//                } else if !downAnimation {
//                    //move the water drop downward after tap gesture
//                    particles.isEmitting = false
//                    value.entity.components.remove(ParticleEmitterComponent.self)
//                    value.entity.components[ParticleEmitterComponent.self] = pSystem()
//                    var transform = value.entity.transform
//                    transform.translation += SIMD3(0.70, -0.55, -1)
//                    let radians = -30 * Float.pi / 180
//                    transform.rotation = simd_quatf(angle: radians, axis: SIMD3<Float>(0,1,0))
//                    value.entity.move(to: transform, relativeTo: nil, duration: 1, timingFunction: .easeInOut)
//                    if(transform.translation.y < -0.3){
//                        upAnimation = false
//                        downAnimation = true
//                    }
//                    print("second")
//                }
//            })
//        )
//        
//        // Add "start conversation" button below the water-droplet avatar
//        Button("Start Conversing") {
//            speechRecognizer.startTranscribing()
//        }
//        .padding()
//    }
//    
//    //WaterDrop firework particles
//    func pSystem() -> ParticleEmitterComponent {
//        particles.emitterShape = .sphere
//        particles.burstCount = 100
//        particles.burst()
//        return particles
//    }
//    
//    //Avatar looking at user
//    static func rotateEntityAroundYAxis(entity: Entity, angle: Float){
//        var currentTransform = entity.transform
//        let rotation = simd_quatf(angle: angle, axis: [0, 1, 0])
//        currentTransform.rotation = rotation * currentTransform.rotation
//        entity.transform = currentTransform
//    }
//}
//
//#Preview {
//    WaterView()
//}





import SwiftUI
import RealityKit
import RealityKitContent

struct WaterView: View {
    @State public var upAnimation = false
    @State public var downAnimation = true
    @State var particles = ParticleEmitterComponent()

    @StateObject var speechRecognizer = SpeechRecognizer()

    let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    @State private var count:Int = 1

    @State private var waterDrop: Entity? = nil
    @State var characterEntity: Entity = {
        let headAnchor = AnchorEntity(.head)
        headAnchor.position = [0.70, -0.35, -1]
        let radians = -30 * Float.pi / 180
        WaterView.rotateEntityAroundYAxis(entity: headAnchor, angle: radians)
        return headAnchor
    }()

    var body: some View {
        RealityView { content in
            // Add the initial RealityKit content
            do {
                let immersiveEntity = try await Entity(named: "Immersive", in: realityKitContentBundle)
                characterEntity.addChild(immersiveEntity)
                content.add(characterEntity)
            } catch {
                print("Error in RealityView's make: \(error)")
            }
        }
        .gesture(TapGesture()
            .targetedToAnyEntity()
            .onEnded({ value in print("Tapped work \(value.entity)")
                if !upAnimation{
                    //move the water drop upward after tap gesture
                    particles.isEmitting = false
                    value.entity.components.remove(ParticleEmitterComponent.self)
                    value.entity.components[ParticleEmitterComponent.self] = pSystem()
                    var transform = value.entity.transform
                    transform.translation += SIMD3(0.70, -0.15, -1)
                    let radians = -30 * Float.pi / 180
                    transform.rotation = simd_quatf(angle: radians, axis: SIMD3<Float>(0,1,0))
                    value.entity.move(to: transform, relativeTo: nil, duration: 1, timingFunction: .easeInOut)
                    if(transform.translation.y > 0.3){
                        upAnimation = true
                        downAnimation = false
                    }
                    print("first")
                } else if !downAnimation {
                    //move the water drop downward after tap gesture
                    particles.isEmitting = false
                    value.entity.components.remove(ParticleEmitterComponent.self)
                    value.entity.components[ParticleEmitterComponent.self] = pSystem()
                    var transform = value.entity.transform
                    transform.translation += SIMD3(0.70, -0.55, -1)
                    let radians = -30 * Float.pi / 180
                    transform.rotation = simd_quatf(angle: radians, axis: SIMD3<Float>(0,1,0))
                    value.entity.move(to: transform, relativeTo: nil, duration: 1, timingFunction: .easeInOut)
                    if(transform.translation.y < -0.3){
                        upAnimation = false
                        downAnimation = true
                    }
                    print("second")
                }
            })
        )

//        // Add "start conversation" button below the water-droplet avatar
//        Button("Start Conversing") {
//            speechRecognizer.startTranscribing()
//        }
//        .padding()
    }

    //WaterDrop firework particles
    func pSystem() -> ParticleEmitterComponent {
        particles.emitterShape = .sphere
        particles.burstCount = 100
        particles.burst()
        return particles
    }

    //Avatar looking at user
    static func rotateEntityAroundYAxis(entity: Entity, angle: Float){
        var currentTransform = entity.transform
        let rotation = simd_quatf(angle: angle, axis: [0, 1, 0])
        currentTransform.rotation = rotation * currentTransform.rotation
        entity.transform = currentTransform
    }
}

#Preview {
    WaterView()
}
