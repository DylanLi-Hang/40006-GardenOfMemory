//
//  ios_studioApp.swift
//  ios_studio
//
//  Created by Denni O on 3/27/24.
//

import SwiftUI

@main
struct ios_studioApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }.windowStyle(.volumetric)

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }.immersionStyle(selection: .constant(.full), in: .full)
    }
}
