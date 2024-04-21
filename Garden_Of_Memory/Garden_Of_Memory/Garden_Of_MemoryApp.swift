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
    }
    
    var body: some Scene {
        @State var immersionMode: ImmersionStyle = .progressive
//        let previewContainer = PreviewContainer([ChatEntry.self])
        
        WindowGroup {
            ContentView()
                .modelContainer(modelContainer)
//                .modelContainer(previewContainer.container)
//            DisplayConversationView()
                 
        }
        .windowStyle(.plain)
        
        
        WindowGroup(id: "DairyViewController") {
            ListConversationView()
                .modelContainer(modelContainer)
        }
        .windowStyle(.plain)
        
        ImmersiveSpace(id: "WaterDrop") {
            WaterView()
                .modelContainer(modelContainer)
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
