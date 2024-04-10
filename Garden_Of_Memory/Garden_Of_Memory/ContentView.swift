//
//  ContentView.swift
//  Garden_Of_Memory
//
//  Created by Denni O on 3/27/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {

    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    
    @StateObject var speechRecognizer = SpeechRecognizer()

    var body: some View {

        VStack(alignment: .center, content: {
            Text("Welcome to the Garden of Memory.")
            Text("Choose your avatar.")
    
            HStack(content: {
                Button{
                    Task{
                        print("tapped")
//                        await openImmersiveSpace(id: "")
                    }
                } label: {
                    Image("AvatarCat")
                        .resizable()
                        .clipShape(Circle())
                        .frame(width: 300, height: 300)
                }
                Button{
                    Task{
                        print("tapped")
                        await openImmersiveSpace(id: "WaterDrop")
                    }
                } label: {
                    Image("WaterDrop")
                        .resizable()
                        .clipShape(Circle())
                        .frame(width: 300, height: 300)
                }
            })
        })
            .font(.extraLargeTitle2)
            .padding(100)
            .glassBackgroundEffect()
            .buttonStyle(PlainButtonStyle())
        }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}
