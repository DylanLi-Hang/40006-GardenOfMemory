// Initializes a SwiftUI application for managing various immersive and volumetric window views, using a `ModelContainer` to handle data models for Swift Data initialize.

import SwiftUI
import SwiftData

@main
struct Garden_Of_MemoryApp: App {
    let modelContainer: ModelContainer
        
    init() {
        do {
            modelContainer = try ModelContainer(for: ChatEntry.self)
        } catch {
            fatalError("Could not initialize ModelContainer")
        }
        print(URL.applicationSupportDirectory.path(percentEncoded: false))
    }
    
    var body: some Scene {
        @State var immersionMode: ImmersionStyle = .progressive

        WindowGroup (id: "StartView") {
            StartView()
                .modelContainer(modelContainer)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 5000, height: 800)
        
        WindowGroup(id: "WaterDrop") {
            WaterView()
                .modelContainer(modelContainer)
        }
        .windowStyle(.volumetric)
        
        WindowGroup(id:"terrariumObject") {
            TerrariumObjectView()
                .modelContainer(modelContainer)
                 
        }.windowStyle(.volumetric)
        
        WindowGroup(id: "DairyViewController") {
            ListConversationView()
                .modelContainer(modelContainer)
        }
        .windowStyle(.plain)
        
        WindowGroup(id: "GridController") {
            TerrariumGridView()
                .modelContainer(modelContainer)
        }
        .windowStyle(.volumetric)
        

        
//        ImmersiveSpace(id: "WaterDrop") {
//            WaterView()
//                .modelContainer(modelContainer)
//        }
        
        WindowGroup(id: "diaryObject") {
            ImmersiveDiaryView()
                .modelContainer(modelContainer)
        }.windowStyle(.volumetric)
        
        ImmersiveSpace(id: "FullTerrarium"){
            ImmersiveTerrariumView()
                .modelContainer(modelContainer)
        }
        .immersionStyle(selection: $immersionMode, in: .progressive)
        
        ImmersiveSpace(id: "CatCat") {
            CatImmersiveView()
        }
        
    }
}
