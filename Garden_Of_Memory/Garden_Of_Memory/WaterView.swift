//
//  WaterView.swift
//  Garden_Of_Memory
//
//  Created by Yu Ching Wong on 9/4/2024.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct WaterView: View {
    @State public var upAnimation = false
    @State public var downAnimation = true
    @State var particles = ParticleEmitterComponent()

    @StateObject var speechRecognizer = SpeechRecognizer()
    
    @State private var receivedData: String = ""
    
    

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
        RealityView { content, attachments in
            // Add the initial RealityKit content
            do {
                let immersiveEntity = try await Entity(named: "Immersive", in: realityKitContentBundle)
                characterEntity.addChild(immersiveEntity)
                content.add(characterEntity)
                
                if let sceneAttachment1 = attachments.entity(for: "StartConversingButton") {
                    immersiveEntity.addChild(sceneAttachment1)
                    sceneAttachment1.position += SIMD3(0, 0.2, 0)
                }
                
                if let sceneAttachment2 = attachments.entity(for: "DisplayResponse") {
                    immersiveEntity.addChild(sceneAttachment2)
                    sceneAttachment2.position += SIMD3(0, 0.5, 0)
                }
                
            } catch {
                print("Error in RealityView's make: \(error)")
            }
        } update: { content, _ in
            // Update the RealityKit content when SwiftUI state changes
        } attachments: {
            // Attachment 1
            Attachment(id: "StartConversingButton") {
                Button("Start Conversing") {
                    speechRecognizer.startTranscribing()
                }
                .padding()
                .glassBackgroundEffect()
            }
            
            // Attachment 2
            Attachment(id: "DisplayResponse") {
                Text("Response:")
                Text(receivedData)
                    .onAppear {
                        // Call your API and update receivedData on response
                        fetchDataFromAPI()
                    }
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
    
    // Fetch data from ChatGPT's response to display in frontend
    func fetchDataFromAPI() {
        print("Fetching data from ChatGPT API IN FRONTEND...")
        OpenAIService.shared.fetchResponseFromChatGPT(dataString: "") { result in
            switch result {
            case .success(let dataString):
                print("Data fetched successfully.")
                DispatchQueue.main.async {
                    receivedData = dataString
                }
            case .failure(let error):
                print("Error fetching data:", error.localizedDescription)
            }
        }
    }

}

#Preview {
    WaterView()
}
