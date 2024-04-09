//
//  Garden_Of_MemoryApp.swift
//  Garden_Of_Memory
//
//  Created by Denni O on 3/27/24.
//

import SwiftUI

@main
struct Garden_Of_MemoryApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }.windowStyle(.plain)
        
        ImmersiveSpace(id: "WaterDrop") {
            WaterView()
        }
    }
}
