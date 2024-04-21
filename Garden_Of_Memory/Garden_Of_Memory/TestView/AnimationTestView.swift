////
////  AnimationTestView.swift
////  Garden_Of_Memory
////
////  Created by Dylan on 21/4/2024.
////
//
//import SwiftUI
//import RealityKit
//
//struct AnimationTestView: View {
//    @State private var entity: Entity?
//    @State private var currentAnimation: Animation = .idle
//    
//    var body: some View {
//        ZStack {
//            RealityViewContainer(entity: $entity)
//            
//            VStack {
//                Spacer()
//                
//                HStack {
//                    Button("Idle") {
//                        playAnimation(animation: .idle)
//                    }
//                    
//                    Button("Listening") {
//                        playAnimation(animation: .listening)
//                    }
//                    
//                    Button("Wait for Response") {
//                        playAnimation(animation: .waitForResponse)
//                    }
//                    
//                    Button("Responding") {
//                        playAnimation(animation: .responding)
//                    }
//                }
//                .padding()
//            }
//        }
//        .onAppear {
//            loadEntity()
//        }
//    }
//    
//    private func loadEntity() {
////        guard let entityName = "WaterAnimation1" else {
////            return
////        }
//        
//        entity = try? Entity.load(named: "WaterAnimation1")
//    }
//    
//    private func playAnimation(animation: Animation) {
//        guard let entity = entity,
//              let unifiedAnimations = entity.availableAnimations.first else {
//            return
//        }
//        
//        let animationResource = unifiedAnimations.trimmed(start: animation.startTime, duration: animation.duration)
//        entity.playAnimation(animationResource, transitionDuration: 0.6, startsPaused: false)
//        currentAnimation = animation
//    }
//}
