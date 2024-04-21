import SwiftUI
import SwiftData

@main
struct Garden_Of_MemoryApp: App {
    var body: some Scene {
        @State var immersionMode: ImmersionStyle = .progressive
        let previewContainer = PreviewContainer([ChatEntry.self])
        
        WindowGroup {
            ContentView()
//                .modelContainer(previewContainer.container)
//            DisplayConversationView()
//                 .modelContainer(for: ChatEntry.self)
        }.windowStyle(.plain)
        
//        WindowGroup(id: "DairyViewController") {
//            DisplayConversationView()
//        }
//        .windowStyle(.volumetric)
        
        ImmersiveSpace(id: "WaterDrop") {
            WaterView()
//                .modelContainer(previewContainer.container)
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
