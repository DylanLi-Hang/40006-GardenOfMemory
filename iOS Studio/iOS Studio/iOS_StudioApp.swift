//
//  iOS_StudioApp.swift
//  iOS Studio
//
//  Created by Denni O on 3/23/24.
//

import SwiftUI

@main
struct iOS_StudioApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }.windowStyle(.volumetric)

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }.immersionStyle(selection: .constant(.full), in: .full)
    }
}
