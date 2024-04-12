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
    
    @Environment(\.openImmersiveSpace) var openImmersiveTerrarium
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveTerrarium
    
    @State var avatarView = false
    @State var terrarium = false

    var body: some View {

        VStack(alignment: .center, content: {
            Text("Welcome to the Garden of Memory.")
                .font(.extraLargeTitle2)
            Text("Choose your avatar.")
                .font(.extraLargeTitle2)

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
                        .frame(width: 200, height: 200)
                }
                Button{
                    Task{
                        print("OpenAvatar")
                        if terrarium{
                            await dismissImmersiveTerrarium()
                            terrarium = false
                        }
                        await openImmersiveSpace(id: "WaterDrop")
                        avatarView = true
                    }
                } label: {
                    Image("WaterDrop")
                        .resizable()
                        .clipShape(Circle())
                        .frame(width: 200, height: 200)
                }
            }).buttonStyle(PlainButtonStyle())
            
            Spacer()
            Button("Close avatar"){
                Task{
                    if avatarView{
                        await dismissImmersiveSpace()
                        avatarView = false
                    }
                    }
                }.font(.title)
               
               Button{
                   Task{
                       print("OpenTerrarium")
                       if avatarView{
                           await dismissImmersiveSpace()
                           avatarView = false
                       }
                       if !terrarium{
                           await openImmersiveTerrarium(id:"FullTerrarium")
                           terrarium = true
                       }
                   }
               } label: {
                   Text("Open Immersive Terrarium")
                       .font(.title)
               }


            Button("Close immmersive view"){
                Task{
                        print("OpenTerrarium")
                    if avatarView{
                        await dismissImmersiveSpace()
                        avatarView = false
                    }
                    if terrarium{
                        await dismissImmersiveTerrarium()
                        terrarium = false
                    }
                }
            }
            .font(.title)
            
        })
            .padding(100)
            .glassBackgroundEffect()
            
        }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}
