//
//  Garden_Of_MemoryApp.swift
//  Garden_Of_Memory
//
//  Created by Denni O on 3/27/24.
//

import SwiftUI
import SwiftData

@main
struct Garden_Of_MemoryApp: App {
    var body: some Scene {
        @State var immersionMode: ImmersionStyle = .progressive
        
        WindowGroup {
            ContentView()
//            DisplayConversationView()
//                 .modelContainer(for: ChatEntry.self)
        }.windowStyle(.plain)
        
        ImmersiveSpace(id: "WaterDrop") {
            WaterView()
//            ContentView()
        }
        
        ImmersiveSpace(id: "FullTerrarium"){
            ImmersiveTerrariumView()
        }
        .immersionStyle(selection: $immersionMode, in: .progressive)
        
        ImmersiveSpace(id: "CatCat") {
            CatImmersiveView()
        }
        
    }
}
