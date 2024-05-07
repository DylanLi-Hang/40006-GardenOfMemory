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
    
    @State var animationResources: [AnimationResource] = [] // idle, listening, waiting, responding
    @State var idleAnimationController: AnimationPlaybackController? = nil
    @State var listeningAnimationController: AnimationPlaybackController? = nil
    @State var componentResources: [Component] = []
    @State private var currentAnimation: Animation = .idle
    @State var animationControllers = [AnimationPlaybackController]()
    @State var isEmitting = false
    
    @State var waterDropEntity: Entity? = nil
    
    @State var particles = ParticleEmitterComponent()
    
    let viewModel = ViewModel.shared
    @State private var count:Int = 1
    @State private var waterDrop: Entity? = nil
    @State var currentChatEntry: ChatEntry = ChatEntry(date: Date(), mood: 10)
    
    @ObservedObject var speechViewModel: SpeechRecognitionViewModel = SpeechRecognitionViewModel()
    
    var body: some View {
        RealityView { content, attachments in
            do {
//                let immersiveEntity = try await Entity(named: "Immersive", in: realityKitContentBundle)
                let animatedEntity = try await Entity(named: "WaterAnimation", in: realityKitContentBundle)
                
                // Animation Resource 0: idle
                if let unwrappedAnimatedEntity = animatedEntity.findEntity(named: "water_drop_idle") {
                    if let animation = unwrappedAnimatedEntity.availableAnimations.first {
                        animationResources.append(animation.repeat())
                        unwrappedAnimatedEntity.playAnimation(animation.repeat())
                    }
                    waterDropEntity = unwrappedAnimatedEntity
                    content.add(unwrappedAnimatedEntity)
                }
                
                // Animation Resource 1: preloading
                if let unwrappedAnimatedEntity = animatedEntity.findEntity(named: "water_drop_loading") {
                    if let animation = unwrappedAnimatedEntity.availableAnimations.first {
                        animationResources.append(animation)
                    }
                }
                
                // Particle for listening
                if let unwrappedAnimatedEntity = animatedEntity.findEntity(named: "water_drop_listening") {
                    if let particleEmitterComponent = unwrappedAnimatedEntity.components[ParticleEmitterComponent.self] {
                        componentResources.append(particleEmitterComponent)
                    }
                }
                
                // Animation Resource 2: response (Not working one)
                if let unwrappedAnimatedEntity = animatedEntity.findEntity(named: "water_drop_response") {
                    if let animation = unwrappedAnimatedEntity.availableAnimations.first {
                        animationResources.append(animation)
                    }
                }
                
                if let sceneAttachment = attachments.entity(for: "StartConversingButton") {
                    if let water_drop = waterDropEntity {
                        sceneAttachment.position = water_drop.position + [0, 0.35, 0]
                        water_drop.addChild(sceneAttachment, preservingWorldTransform: true)
                    }
                }
                
                if let sceneAttachment = attachments.entity(for: "DisplayResponse") {
                    if let water_drop = waterDropEntity {
                        sceneAttachment.position = water_drop.position + [0, 0.2, 0]
                        water_drop.addChild(sceneAttachment, preservingWorldTransform: true)
                    }
                }
                
                if let sceneAttachment = attachments.entity(for: "PlayAnimation") {
                    content.add(sceneAttachment)
                    sceneAttachment.position += [0, 1.5, -0.5]
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
                    Image("WaterDrop")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                    
                    if viewModel.status == .responding {
                        ScrollView(showsIndicators: true) {
                            Text(speechViewModel.responseText)
                                .padding(.all, 10)
                                .background(Color.gray.opacity(0.25))
                                .cornerRadius(20)
                                .multilineTextAlignment(.leading)
                                .frame(width: 600, height: 150, alignment: .leading)
                        }
                    } else {
                        ScrollView(showsIndicators: true) {
                            Text(speechViewModel.messages.last?.content ?? "No messages yet")
                                .padding(.all, 10)
                                .background(Color.gray.opacity(0.25))
                                .cornerRadius(20)
                                .multilineTextAlignment(.leading)
                                .frame(width: 600, height: 150, alignment: .leading)
                        }
                    }
                }
                .padding(.all, 10)
                .background(Color.black.opacity(0.5))
                .cornerRadius(25)
                .shadow(color: .gray, radius: 3, x: 1, y: 1)
                .padding(.horizontal, 10)
                .frame(width: 800, height: 200)
            }
            
            Attachment(id: "PlayAnimation") {
                HStack{
                    Button {
                        viewModel.status = viewModel.status.next()
                        print("Current Status: \(viewModel.status)")
                    } label: {
                        Text("Status Control")
                    }
                    
                    Button {
                        waterDropEntity?.components[ParticleEmitterComponent.self]?.burst()
                    } label: {
                        Text("Burst")
                    }
                    
                    ForEach(animationControllers.indices, id: \.self) { index in
                        let controller = animationControllers[index]
                        Button("PlayAnimation") {
                            if controller.isPlaying == false {
                                controller.resume()
                            } else {
                                controller.pause()
                            }
                        }
                        .padding()
                        .glassBackgroundEffect()
                    }
                }
                
            }
        }
        .onChange(of: viewModel.status, { oldValue, newValue in
            if oldValue == .listening && newValue != .listening {
                if let unwrappedAnimatedEntity = waterDropEntity {
                    unwrappedAnimatedEntity.components.remove(ParticleEmitterComponent.self)
                }
            }
            
//            if oldValue == .notListening && newValue != .notListening {
//                let rotationTransform = Transform(rotation: simd_quatf(angle: .pi, axis: [0,1,0]))
//                if let unwrappedAnimatedEntity = waterDropEntity {
//                    unwrappedAnimatedEntity.move(to: rotationTransform, relativeTo: unwrappedAnimatedEntity.self, duration: 3.0)
//                }
//            }
            
            if newValue == .listening {
                if let unwrappedAnimatedEntity = waterDropEntity {
                    unwrappedAnimatedEntity.components.set(componentResources)
                }
                
                waterDropEntity?.components[ParticleEmitterComponent.self]?.burst()
            } else if newValue == .idle {
                dropAnimation()
                if let unwrappedAnimatedEntity = waterDropEntity {
                    unwrappedAnimatedEntity.components.set(componentResources)
                }
                if let unwrappedAnimatedEntity = waterDropEntity {
                    guard let idleAnimation = animationResources.first else { return }
                    let controller = unwrappedAnimatedEntity.playAnimation(idleAnimation, transitionDuration: 0.6, startsPaused: false)
                    animationControllers.append(controller)
                    print("play idle animation")
                }
            } else if newValue == .responding {
                dropAnimation()
                if let unwrappedAnimatedEntity = waterDropEntity {
                    guard animationResources.count > 2 else { return }
                    guard let completeResponseAnimation = try? AnimationResource.sequence(with: [animationResources[1], animationResources[2]]) else {
                        return
                    }
                    let controller = unwrappedAnimatedEntity.playAnimation(completeResponseAnimation, transitionDuration: 0.6, startsPaused: false)
                    animationControllers.append(controller)
                    print("play loading animation")
                }
            } else if newValue == .waitForResponse {
                dropAnimation()
                if let unwrappedAnimatedEntity = waterDropEntity {
                    guard animationResources.count > 2 else { return }
                    let respondingAnimation = animationResources[2]
                    let controller = unwrappedAnimatedEntity.playAnimation(respondingAnimation, transitionDuration: 0.6, startsPaused: false)
                    animationControllers.append(controller)
                    print("play loading animation")
                }
            } 
//            else if viewModel.status == .notListening {
//                let rotationTransform = Transform(rotation: simd_quatf(angle: .pi, axis: [0,1,0]))
//                if let unwrappedAnimatedEntity = waterDropEntity {
//                    unwrappedAnimatedEntity.move(to: rotationTransform, relativeTo: unwrappedAnimatedEntity.self, duration: 3.0)
//                }
//            }
        })
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
    }
    
    func dropAnimation() {
        for animationController in animationControllers {
            animationController.stop(blendOutDuration: 1)
            animationControllers.removeFirst()
        }
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
    
}

#Preview {
    WaterView()
}


// Learning Code
// Thanks for https://stackoverflow.com/questions/76599901/how-to-use-multiple-animations-on-a-usdz-model-with-realitykit/76600896#76600896
// Thanks for https://blog.studiolanes.com/posts/unified-animation-timeline

 
/*struct ContentView : View {
    
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
}*/
