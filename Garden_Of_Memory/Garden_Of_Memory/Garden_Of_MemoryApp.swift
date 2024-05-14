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
        
        WindowGroup {
            ContentView()
                .modelContainer(modelContainer)
        }
        .windowStyle(.plain)
        
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
