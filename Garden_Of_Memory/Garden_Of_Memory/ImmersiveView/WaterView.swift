//
//  WaterView.swift
//  Garden_Of_Memory
//
//  Created by Yu Ching Wong on 9/4/2024.
//

import SwiftUI
import SwiftData
import RealityKit
import RealityKitContent
import OpenAIKit

struct WaterView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ChatEntry.date, order: .reverse) private var entries: [ChatEntry]
    
    @State public var upAnimation = false
    @State public var downAnimation = true
    let animatedEntity = try? Entity.load(named: "WaterAnimation1", in: realityKitContentBundle)
    @State var animationResources: [AnimationResource] = []
    @State var animationController: AnimationPlaybackController? = nil
    @State var animationController2: AnimationPlaybackController? = nil
    @State private var currentAnimation: Animation = .idle
    @State var animationControllers = [AnimationPlaybackController]()
    
    @State var particles = ParticleEmitterComponent()
    
    let viewModel = ViewModel.shared
    @State private var count:Int = 1
    @State private var waterDrop: Entity? = nil
    @State var currentChatEntry: ChatEntry = ChatEntry(date: Date(), mood: 10)
    
    @ObservedObject var speechViewModel: SpeechRecognitionViewModel = SpeechRecognitionViewModel()

    var body: some View {
        RealityView { content, attachments in
            do {
                let immersiveEntity = try await Entity(named: "Immersive", in: realityKitContentBundle)
                
                content.add(immersiveEntity)
                if let sceneAttachment = attachments.entity(for: "StartConversingButton") {
                    if let water_drop = immersiveEntity.findEntity(named: "water_drop_idle") {
                        sceneAttachment.position = water_drop.position + [0, 0.2, 0]
                        water_drop.addChild(sceneAttachment, preservingWorldTransform: true)
                    }
                }
                
                if let sceneAttachment = attachments.entity(for: "DisplayResponse") {
                    if let water_drop = immersiveEntity.findEntity(named: "water_drop_idle") {
                        sceneAttachment.position = water_drop.position + [0.5, 0, 0]
                        water_drop.addChild(sceneAttachment, preservingWorldTransform: true)
                    }
                }
            } catch {
                print("Error in RealityView's make: \(error)")
            }
        } update: { content, _ in
            // Update the RealityKit content when SwiftUI state changes
        } attachments: {
            // Attachment 1
            Attachment(id: "StartConversingButton") {
                VStack {
                    Text("Current Status: \(viewModel.status)")
                        .glassBackgroundEffect()
                    if speechViewModel.recognizationStatus == false {
                        Button("Start Conversing") {
                            speechViewModel.changeRecognitionStatus()
                        }
                        .padding()
                        .glassBackgroundEffect()
                    } else {
                        Button("Stop Conversing") {
                            speechViewModel.changeRecognitionStatus()
                            currentChatEntry.chatMessages = speechViewModel.messages
                        }
                        .padding()
                        .glassBackgroundEffect()
                    }
                }
            }
            
            // Attachment 2
            Attachment(id: "DisplayResponse") {
                HStack {
                    Text("Response:  ")
                    if viewModel.status == .responding {
                        ScrollView(.horizontal, showsIndicators: true) {
                            Text(speechViewModel.responseText)
                                .frame(alignment: .leading)
                                .padding(80)
                                .multilineTextAlignment(.leading)
                        }
                    } else {
                        Text(speechViewModel.messages.last?.content ?? "No messages yet")
                    }
                }
                .frame(width: 800, height: 1000)
                .glassBackgroundEffect()
            }

        }
        .onAppear() {
            var isloaded = false
            if !entries.isEmpty {
                if let todayEntry = entries.first {
                    let calendar = Calendar.current
                    if calendar.isDate(todayEntry.date, equalTo: Date(), toGranularity: .day) {
                        self.currentChatEntry = todayEntry
                        speechViewModel.messages = self.currentChatEntry.chatMessages
                        isloaded = true
                    }
                }
            }
            if !isloaded {
                modelContext.insert(self.currentChatEntry)
            }
        }
        .gesture(TapGesture()
            .targetedToAnyEntity()
            .onEnded({ value in 
                print("Tapped work \(value.entity)")
                
            })
        )
    }

    
    func loadAnimation() {
        for animation in Animation.allCases {
            if let animatedEntity = try? Entity.load(named: animation.rawValue+"Scene", in: realityKitContentBundle) {
                
                if let true_animatedEntity = animatedEntity.findEntity(named: "WaterL") {
                    let animationResource = true_animatedEntity.availableAnimations[0]
                    animationResources.append(animationResource)
                    
                    print("loaded animation \(animation.rawValue)")
                }
                
            }
        }
    }

    func play(animation: Animation) -> AnimationResource? {
        if let matchingEntity = try? Entity.load(named: animation.rawValue),
            let animation = matchingEntity.availableAnimations.first {
            return animation
        } else {
            return nil
        }
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


// Learning Code
// Thanks for https://stackoverflow.com/questions/76599901/how-to-use-multiple-animations-on-a-usdz-model-with-realitykit/76600896#76600896
// Thanks for https://blog.studiolanes.com/posts/unified-animation-timeline
/*
 
 struct ContentView : View {

     @State var animationResource: [AnimationResource] = []
     @State var model1 = try! Entity.loadModel(named: "idle.usdz")
     @State var model2 = try! Entity.loadModel(named: "jump.usdz")
     
     var body : some View {
         ZStack {
             ARViewContainer(model: $model1)
                 .ignoresSafeArea()
                 .onAppear {
                     animationResource.append(model1.availableAnimations[0])
                     animationResource.append(model2.availableAnimations[0])
                 }
             VStack {
                 Spacer()
                 HStack {
                     Spacer()
                     Button("Jump") {
                         model1.playAnimation(animationResource[1].repeat(),
                                              transitionDuration: 0.5)
                     }
                     Spacer()
                     Button("Neutral") {
                         model1.playAnimation(animationResource[0].repeat(),
                                              transitionDuration: 0.5)
                     }
                     Spacer()
                 }
             }
         }
     }
 }
 */
