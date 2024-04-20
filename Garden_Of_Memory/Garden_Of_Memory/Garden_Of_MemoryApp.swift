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
