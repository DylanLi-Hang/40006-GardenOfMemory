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
    
    @State var waterDropEntity: Entity? = nil
    @ObservedObject var speechViewModel: SpeechRecognitionViewModel = SpeechRecognitionViewModel()
    
    @State var animationResources: [AnimationResource] = [] // idle, listening, waiting, responding
    @State var componentResources: [Component] = []
    @State var animationControllers = [AnimationPlaybackController]()
    
    let viewModel = ViewModel.shared
    @State private var count: Int = 1
    @State private var waterDrop: Entity? = nil
    @State var currentChatEntry: ChatEntry = ChatEntry(date: Date(), mood: 10)
    
    var body: some View {
        RealityView { content, attachments in
            do {
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
        .onChange(of: speechViewModel.mood, { oldValue, newValue in
            currentChatEntry.mood = speechViewModel.mood
        })
        .onChange(of: speechViewModel.tags, { oldValue, newValue in
            currentChatEntry.tags = speechViewModel.tags
        })
        .onChange(of: viewModel.status, { oldValue, newValue in
            if oldValue == .listening && newValue != .listening {
                if let unwrappedAnimatedEntity = waterDropEntity {
                    unwrappedAnimatedEntity.components.remove(ParticleEmitterComponent.self)
                }
            }
            
            if newValue == .listening {
                if let unwrappedAnimatedEntity = waterDropEntity {
                    unwrappedAnimatedEntity.components.set(componentResources)
                }
                
                var count = 1
                _ = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                    waterDropEntity?.components[ParticleEmitterComponent.self]?.burst()
                    if count > 4 {
                        timer.invalidate()
                    }
                    count += 1
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
