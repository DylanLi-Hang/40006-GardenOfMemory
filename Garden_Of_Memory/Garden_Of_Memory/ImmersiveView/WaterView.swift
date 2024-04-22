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
                let immersiveEntity = try await Entity(named: "idleScene", in: realityKitContentBundle)
                let animationEntity = immersiveEntity.findEntity(named: "WaterL")

                content.add(immersiveEntity)
                
                
                // Not working: from WaterAnimation1
                if let unwrappedAnimatedEntity = animatedEntity?.findEntity(named: "WaterL") {
                   if let animation = unwrappedAnimatedEntity.availableAnimations.first {
                       var animationDefinition = animation.definition
                       var def = animationDefinition.trimmed(start: viewModel.animation.startTime, duration: viewModel.animation.duration)
                       let animation_trimmed = try! AnimationResource.generate(with: def).repeat()
                       let controller = unwrappedAnimatedEntity.playAnimation(animation_trimmed, transitionDuration: 0.6, startsPaused: false)
                   }
               }
                
                // Working: from idleScene
                if let unwrappedAnimatedEntity = animationEntity {
                    if let animation = unwrappedAnimatedEntity.availableAnimations.first {
                        var animationDefinition = animation.definition
                        var def = animationDefinition.trimmed(start: viewModel.animation.startTime, duration: viewModel.animation.duration)
                        let animation_trimmed = try! AnimationResource.generate(with: def).repeat()
                        let controller = unwrappedAnimatedEntity.playAnimation(animation_trimmed, transitionDuration: 0.6, startsPaused: false)
                    }
                }
                
                // Add simple animation: This one works
                /*
                let animationDefinition = FromToByAnimation(to: Transform(translation: [0.1, 0, 0]), bindTarget: .transform)
                let animationResource = try! AnimationResource.generate(with: animationDefinition)
                animationResources.append(animationResource)
                 
                 */
                
                // Use animation from WaterAnimation1: This one works
                /*
                 if let unwrappedAnimatedEntity = animatedEntity {
                    print("Animation Loaded")
                    content.add(unwrappedAnimatedEntity)
                    if let animation = unwrappedAnimatedEntity.availableAnimations.first {
                        var animationDefinition = animation.definition
                        var def = animationDefinition.trimmed(start: viewModel.animation.startTime, duration: viewModel.animation.duration)
                            print(def)
                        let animation_trimmed = try! AnimationResource.generate(with: def).repeat()
                            let controller = unwrappedAnimatedEntity.playAnimation(animation_trimmed, transitionDuration: 0.6, startsPaused: false)
                            print(animation_trimmed)
                    }
                }
                 */

//               if let animation = immersiveEntity.availableAnimations.first {
//                   let controller = immersiveEntity.playAnimation(animation, transitionDuration: 0.6, startsPaused: false)
                   
//                   var animationDefinition = animation.definition
//                   var def = animationDefinition.trimmed(start: viewModel.animation.startTime, duration: viewModel.animation.duration)
//                   let animationGenerated = try! AnimationResource.generate(with: def).repeat()
//                   let controller = immersiveEntity.playAnimation(animationGenerated, transitionDuration: 0.6, startsPaused: false)
//               }
                
                // Use animaton from idleScene: This one is working
                /*if let unwrappedAnimatedEntity = animationEntity {
                    print("Animation Loaded")
                    content.add(unwrappedAnimatedEntity)
                    if let animation = unwrappedAnimatedEntity.availableAnimations.first {
                        var animationDefinition = animation.definition
                        var def = animationDefinition.trimmed(start: viewModel.animation.startTime, duration: viewModel.animation.duration)
                            print(def)
                        let animation_trimmed = try! AnimationResource.generate(with: def).repeat()
                            let controller = unwrappedAnimatedEntity.playAnimation(animation_trimmed, transitionDuration: 0.6, startsPaused: false)
                            print(animation_trimmed)
                    }
                }*/
                
                // Use animaton from idleScene: This one is working
                /*if let anime = animationEntity?.availableAnimations.first {
                    var animedef = anime.definition
                    var resource = try AnimationResource.generate(with: animedef)
                    animationResources.append(resource)
                    let controller = animationEntity!.playAnimation(resource, transitionDuration: 0.6, startsPaused: false)
                }*/

                // Use animaton from idleScene: This one is not working
                /*if let anime = animationEntity?.availableAnimations.first {
                    var animedef = anime.definition
                    var resource = try AnimationResource.generate(with: animedef)
                    animationResources.append(resource)
                    immersiveEntity.playAnimation(animationResources[0])
                }*/
                
                // Use animaton from idleScene: This one is working
                /*if let anime = animationEntity?.availableAnimations.first {
                    var animedef = anime.definition
                    var resource = try AnimationResource.generate(with: animedef)
                    animationResources.append(resource)
                    animationEntity!.playAnimation(animationResources[0])
                }*/
                
                if let sceneAttachment = attachments.entity(for: "StartConversingButton") {
                    if let water_drop = immersiveEntity.findEntity(named: "water_drop") {
                        sceneAttachment.position = water_drop.position + [0, 0.2, 0]
                        water_drop.addChild(sceneAttachment, preservingWorldTransform: true)
                    }
                }
                
                if let sceneAttachment = attachments.entity(for: "DisplayResponse") {
                    if let water_drop = immersiveEntity.findEntity(named: "water_drop") {
                        sceneAttachment.position = water_drop.position + [0, -0.2, 0]
                        water_drop.addChild(sceneAttachment, preservingWorldTransform: true)
                    }
                }
                
                if let sceneAttachment = attachments.entity(for: "PlayAnimation") {
                    content.add(sceneAttachment)
                }
                
            } catch {
                print("Error in RealityView's make: \(error)")
            }
        } update: { content, _ in
            // Update the RealityKit content when SwiftUI state changes
        } attachments: {
            // Attachment 1
            Attachment(id: "StartConversingButton") {
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
            
            // Attachment 2
            Attachment(id: "DisplayResponse") {
                HStack {
                    Text("Response:")
                    if viewModel.status == .responding {
                        Text(speechViewModel.responseText)
                    } else {
                        Text(speechViewModel.messages.last?.content ?? "No messages yet")
                    }
                }.frame(width: 1000)
                .glassBackgroundEffect()
            }
            
            Attachment(id: "PlayAnimation") {
                HStack{
                    Button("PlayAnimation") {
                        if animationController != nil && animationController?.isPlaying == false {
                            print("Resume")
                            animationController?.resume()
                        } else {
                            print("Stop")
                            animationController?.stop()
                        }
                    }
                    .padding()
                    .glassBackgroundEffect()
                    
                    Button("PlayAnimation2") {
                        if animationController2 != nil && animationController2?.isPlaying == false {
                            print("2Resume")
                            animationController2?.resume()
                        } else {
                            print("2Stop")
                            animationController2?.pause()
                        }
                    }
                    .padding()
                    .glassBackgroundEffect()
                }
                
            }
        }
        .onChange(of: viewModel.status, { oldValue, newValue in
            
        })
        .onAppear() {
            
            var isloaded = false
            if !entries.isEmpty {
                if let todayEntry = entries.first {
                    if todayEntry.date == Date() {
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
//                print("Tapped work \(value.entity)")
                
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
