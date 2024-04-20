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
    
    @State var globalVariable: String = ""
    private let openaiservice = OpenAIService()
    
    let timer = Timer.publish(every: 10.0, on: .main, in: .common).autoconnect()
    @State private var count:Int = 1

    @State private var waterDrop: Entity? = nil
    var body: some View {
        RealityView { content, attachments in
            do {
                let immersiveEntity = try await Entity(named: "Immersive", in: realityKitContentBundle)
                
                content.add(immersiveEntity)
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
                Text(globalVariable)
            }
        }
        .onReceive(timer) { _ in // Observe changes to savedContent
            globalVariable.append(GlobalVariables.dataString)
            
            print("(FRONTEND) Timer received")
            print("(FRONTEND) Current content in responseViewModel:", globalVariable)
        }
        .onAppear {
            // Start the timer when the view appears
            timer
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
                    transform.translation += SIMD3(0, 0.2, 0)
                    value.entity.move(to: transform, relativeTo: nil, duration: 1, timingFunction: .easeInOut)
                    if(transform.translation.y > 1.51){
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
                    transform.translation += SIMD3(0, -0.2, 0)
                    value.entity.move(to: transform, relativeTo: nil, duration: 1, timingFunction: .easeInOut)
                    if(transform.translation.y < 1.49){
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

}

#Preview {
    WaterView()
}
