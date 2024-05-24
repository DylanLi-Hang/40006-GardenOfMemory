import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    
    @Environment(\.openImmersiveSpace) var openImmersiveTerrarium
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveTerrarium
    
    @State var avatarView: Bool = false
    @State private var isDairyViewOpen: Bool = false
    @State private var isDiaryObjViewOpen: Bool = false
    @State private var isTerraObjViewOpen: Bool = false
    
    let viewModel = ViewModel.shared
    
    var body: some View {
        
        VStack(alignment: .center) {
            Text("Welcome to the Garden of Memory.")
                .font(.extraLargeTitle2)
            Text("Choose your avatar.")
                .font(.extraLargeTitle2)
            
            HStack(content: {
                Button{
                    Task{
                        print("tapped")
                        await openImmersiveSpace(id: "CatCat")
                    }
                } label: {
                    Image("AvatarCat")
                        .resizable()
                        .clipShape(Circle())
                        .frame(width: 200, height: 200)
                }
                Button{
                    Task{
                        print("OpenAvatar")
                        openWindow(id: "WaterDrop")
                        avatarView = true
                    }
                } label: {
                    Image("WaterDrop")
                        .resizable()
                        .clipShape(Circle())
                        .frame(width: 200, height: 200)
                }
            }).buttonStyle(PlainButtonStyle())
            
            Spacer()
            Button("Close avatar"){
                Task{
                    if avatarView{
                        await dismissImmersiveSpace()
                        avatarView = false
                    }
                }
            }.font(.title)
            
            Button{
                Task{
                    print("OpenTerrarium")
                    if avatarView{
                        await dismissImmersiveSpace()
                        avatarView = false
                    }
                    if !viewModel.terrarium{
                        await openImmersiveTerrarium(id:"FullTerrarium")
                        viewModel.terrarium = true
                        print(viewModel.terrarium)
                    }
                }
            } label: {
                Text("Open Immersive Terrarium")
                    .font(.title)
            }
            
            Button("Add Terrarium Object"){
                isTerraObjViewOpen.toggle()
            }
            .font(.title)
            
            Button("Add Diary Object"){
                isDiaryObjViewOpen.toggle()
            }
            .font(.title)
            
            Button("Close immmersive view"){
                Task{
                    print("CloseTerrarium")
                    if avatarView{
                        await dismissImmersiveSpace()
                        avatarView = false
                    }
                    if viewModel.terrarium{
                        await dismissImmersiveTerrarium()
                        viewModel.terrarium = false
                        print(viewModel.terrarium)
                    }
                }
            }
            .font(.title)
            
            Button("View Data"){
                isDairyViewOpen.toggle()
            }
            .font(.title)
            
        }
        .padding(100)
        .glassBackgroundEffect()
        .onChange(of: isDairyViewOpen) { _, newValue in
            Task {
                if newValue {
                    openWindow(id: "DairyViewController")
                } else {
                    dismissWindow(id: "DairyViewController")
                }
            }
        }
        .onChange(of: isTerraObjViewOpen) { _, newValue in
            Task {
                if newValue {
                    openWindow(id: "terrariumObject")
                } else {
                    dismissWindow(id: "terrariumObject")
                }
            }
        }
        .onChange(of: isDiaryObjViewOpen) { _, newValue in
            Task {
                if newValue {
                    openWindow(id: "diaryObject")
                } else {
                    dismissWindow(id: "diaryObject")
                }
            }
        }
        
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}
