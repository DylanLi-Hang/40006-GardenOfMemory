//
//  NewContentView.swift
//  Garden_Of_Memory
//
//  Created by Dylan on 14/5/2024.
//

import SwiftUI
import SwiftData
import RealityKit
import RealityKitContent

struct NewContentView: View {
    
    @State var bounceValue: Int = 0
    @State private var isAvatarButtonActive = false
    @State private var isMicrophoneButtonActive = false
    @State private var isDiaryButtonActive = false
    @State private var isTerrariumButtonActive = false
    
    var body: some View {
        
        RealityView { content, attachments in
            if let sceneAttachment = attachments.entity(for: "ControlCenter") {
                content.add(sceneAttachment)
                sceneAttachment.position += [0, -0.4, 0.45]
            }
        } update: { content, _ in
            
        } attachments: {
            Attachment(id: "ControlCenter") {
                HStack(spacing: 10) {
                    // Avatar Button
                    Button(action: {
                        isAvatarButtonActive.toggle()
                        bounceValue += 1
                    }) {
                        Image(systemName: "drop")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .padding()
                            .background(Circle().fill(isAvatarButtonActive ? Color.blue : Color.white.opacity(0.2)))
                            .clipShape(Circle())
                            .symbolEffect(
                                .bounce,
                                options: .repeat(1),
                                value: bounceValue
                            )
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .symbolEffect(.bounce, value: 1)
                    
                    // Microphone Button
                    Button(action: {
                        isMicrophoneButtonActive.toggle()
                    }) {
                        Image(systemName: "mic")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .padding()
                            .background(Circle().fill(isMicrophoneButtonActive ? Color.yellow : Color.white.opacity(0.2)))
                            .clipShape(Circle())
                        
                    }.buttonStyle(BorderlessButtonStyle())
                    
                    // Diary Button
                    Button(action: {
                        isDiaryButtonActive.toggle()
                    }) {
                        Image(systemName: "book")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .padding()
                            .background(Circle().fill(isDiaryButtonActive ? Color.red : Color.white.opacity(0.2)))
                            .clipShape(Circle())
                    }.buttonStyle(BorderlessButtonStyle())
                    
                    // Terrarium Button
                    Button(action: {
                        isTerrariumButtonActive.toggle()
                    }) {
                        Image(systemName: "tree")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .padding()
                            .background(Circle().fill(isTerrariumButtonActive ? Color.green : Color.white.opacity(0.2)))
                            .clipShape(Circle())
                    }.buttonStyle(BorderlessButtonStyle())
                }
                .padding()
                .clipShape(Capsule())
                .glassBackgroundEffect()
            }
        }
    }
    
}

#Preview {
    NewContentView()
}
