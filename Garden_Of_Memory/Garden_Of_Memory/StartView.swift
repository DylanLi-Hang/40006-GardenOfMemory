//
//  StartImmersiveView.swift
//  Garden_Of_Memory
//
//  Created by Dylan on 22/5/2024.
//
// This code defines the `StartView` SwiftUI view for the "Garden of Memory" app, as a start screen with animated text and a button to open a avatar, providing an immersive and visually engaging introduction.

import SwiftUI
import RealityKit
import RealityKitContent
import AVFoundation

struct StartView: View {
    
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    @Environment(\.dismiss) private var dismiss
    
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    
    @State private var isVisible = false

    var body: some View {
        VStack (alignment: .center) {
            Text("Garden of Memory")
                .font(.system(size: 200))
                .bold()
                .opacity(isVisible ? 1 : 0)
                .animation(.easeIn(duration: 2), value: isVisible)
                .preferredSurroundingsEffect(.systemDark)
            
            Spacer()
                .frame(height:100)
            
            Text("A peaceful space to nurture your feelings")
                .font(.system(size: 120))
                .opacity(isVisible ? 1 : 0)
                .animation(.easeIn(duration: 2).delay(1), value: isVisible)
                .preferredSurroundingsEffect(.systemDark)
            
            Spacer()
            
            Button {
                openWindow(id: "WaterDrop")
            } label: {
                Text("Meet Your Companion")
                    .font(.system(size: 100))
                    .bold()
                    .opacity(isVisible ? 1 : 0)
                    .animation(.easeIn(duration: 2).delay(2), value: isVisible)
                    .padding()
            }
            .preferredSurroundingsEffect(.systemDark)
            .buttonBorderShape(.roundedRectangle(radius: 200))
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 50)
                    .stroke(Color.primary, lineWidth: 2)
            )
        }
        .preferredSurroundingsEffect(.systemDark)
        .onAppear {
            self.isVisible = true
            AudioManager.shared.playStartAudio(named: "StartSound.mp3")
            print("Playing StartSound.mp3")
        }
    }
}

#Preview {
    StartView()
}
