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
        WindowGroup {
//            ContentView()
            DisplayConversationView()
                .modelContainer(for: ChatEntry.self)
        }

//        ImmersiveSpace(id: "ImmersiveSpace") {
//            ImmersiveView()
//        }.immersionStyle(selection: .constant(.full), in: .full)
    }
}
