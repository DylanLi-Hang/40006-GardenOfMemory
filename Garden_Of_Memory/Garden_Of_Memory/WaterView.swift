//
//  WaterView.swift
//  Garden_Of_Memory
//
//  Created by Yu Ching Wong on 9/4/2024.
//

//import SwiftUI
//import RealityKit
//import RealityKitContent
//
//struct WaterView: View {
//    @State public var upAnimation = false
//    @State public var downAnimation = true
//    @State var particles = ParticleEmitterComponent()
//
//    @StateObject var speechRecognizer = SpeechRecognizer()
//    
//    @State private var receivedData: String = ""
//    
//    
//
//    let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
//    @State private var count:Int = 1
//
//    @State private var waterDrop: Entity? = nil
//    @State var characterEntity: Entity = {
//        let headAnchor = AnchorEntity(.head)
//        headAnchor.position = [0.70, -0.35, -1]
//        let radians = -30 * Float.pi / 180
//        WaterView.rotateEntityAroundYAxis(entity: headAnchor, angle: radians)
//        return headAnchor
//    }()
//
//    var body: some View {
//        RealityView { content, attachments in
//            // Add the initial RealityKit content
//            do {
//                let immersiveEntity = try await Entity(named: "Immersive", in: realityKitContentBundle)
//                characterEntity.addChild(immersiveEntity)
//                content.add(characterEntity)
//                
//                if let sceneAttachment1 = attachments.entity(for: "StartConversingButton") {
//                    immersiveEntity.addChild(sceneAttachment1)
//                    sceneAttachment1.position += SIMD3(0, 0.2, 0)
//                }
//                
//                if let sceneAttachment2 = attachments.entity(for: "DisplayResponse") {
//                    immersiveEntity.addChild(sceneAttachment2)
//                    sceneAttachment2.position += SIMD3(0, 0.5, 0)
//                }
//                
//            } catch {
//                print("Error in RealityView's make: \(error)")
//            }
//        } update: { content, _ in
//            // Update the RealityKit content when SwiftUI state changes
//        } attachments: {
//            // Attachment 1
//            Attachment(id: "StartConversingButton") {
//                Button("Start Conversing") {
//                    speechRecognizer.startTranscribing()
//                }
//                .padding()
//                .glassBackgroundEffect()
//            }
//            
//            // Attachment 2
//            Attachment(id: "DisplayResponse") {
//                Text("Response:")
//                Text(receivedData)
//                    .onAppear {
//                        // Call your API and update receivedData on response
//                        fetchDataFromAPI()
//                    }
//            }
//        }
//        .gesture(TapGesture()
//            .targetedToAnyEntity()
//            .onEnded({ value in print("Tapped work \(value.entity)")
//                if !upAnimation{
//                    //move the water drop upward after tap gesture
//                    particles.isEmitting = false
//                    value.entity.components.remove(ParticleEmitterComponent.self)
//                    value.entity.components[ParticleEmitterComponent.self] = pSystem()
//                    var transform = value.entity.transform
//                    transform.translation += SIMD3(0.70, -0.15, -1)
//                    let radians = -30 * Float.pi / 180
//                    transform.rotation = simd_quatf(angle: radians, axis: SIMD3<Float>(0,1,0))
//                    value.entity.move(to: transform, relativeTo: nil, duration: 1, timingFunction: .easeInOut)
//                    if(transform.translation.y > 0.3){
//                        upAnimation = true
//                        downAnimation = false
//                    }
//                    print("first")
//                } else if !downAnimation {
//                    //move the water drop downward after tap gesture
//                    particles.isEmitting = false
//                    value.entity.components.remove(ParticleEmitterComponent.self)
//                    value.entity.components[ParticleEmitterComponent.self] = pSystem()
//                    var transform = value.entity.transform
//                    transform.translation += SIMD3(0.70, -0.55, -1)
//                    let radians = -30 * Float.pi / 180
//                    transform.rotation = simd_quatf(angle: radians, axis: SIMD3<Float>(0,1,0))
//                    value.entity.move(to: transform, relativeTo: nil, duration: 1, timingFunction: .easeInOut)
//                    if(transform.translation.y < -0.3){
//                        upAnimation = false
//                        downAnimation = true
//                    }
//                    print("second")
//                }
//            })
//        )
//    }
//
//
//    //WaterDrop firework particles
//    func pSystem() -> ParticleEmitterComponent {
//        particles.emitterShape = .sphere
//        particles.burstCount = 100
//        particles.burst()
//        return particles
//    }
//
//    //Avatar looking at user
//    static func rotateEntityAroundYAxis(entity: Entity, angle: Float){
//        var currentTransform = entity.transform
//        let rotation = simd_quatf(angle: angle, axis: [0, 1, 0])
//        currentTransform.rotation = rotation * currentTransform.rotation
//        entity.transform = currentTransform
//    }
//    
//    // Fetch data from ChatGPT's response to display in frontend
//    func fetchDataFromAPI() {
//        print("Fetching data from ChatGPT API IN FRONTEND...")
//        OpenAIService.shared.fetchResponseFromChatGPT(dataString: "") { result in
//            switch result {
//            case .success(let dataString):
//                print("Data fetched successfully.")
//                DispatchQueue.main.async {
//                    receivedData = dataString
//                }
//            case .failure(let error):
//                print("Error fetching data:", error.localizedDescription)
//            }
//        }
//    }
//
//}
//
//#Preview {
//    WaterView()
//}





//import SwiftUI
//import RealityKit
//import RealityKitContent
//
//struct WaterView: View {
//    @State public var upAnimation = false
//    @State public var downAnimation = true
//    @State var particles = ParticleEmitterComponent()
//
//    @StateObject var speechRecognizer = SpeechRecognizer()
//    
//    @State var storedResponses: [String] = []
//
//
//        
//    let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
//    @State private var count:Int = 1
//
//    @State private var waterDrop: Entity? = nil
//    @State var characterEntity: Entity = {
//        let headAnchor = AnchorEntity(.head)
//        headAnchor.position = [0.70, -0.35, -1]
//        let radians = -30 * Float.pi / 180
//        WaterView.rotateEntityAroundYAxis(entity: headAnchor, angle: radians)
//        return headAnchor
//    }()
//
//    var body: some View {
//        RealityView { content, attachments in
//            // Add the initial RealityKit content
//            do {
//                let immersiveEntity = try await Entity(named: "Immersive", in: realityKitContentBundle)
//                characterEntity.addChild(immersiveEntity)
//                content.add(characterEntity)
//                
//                if let sceneAttachment1 = attachments.entity(for: "StartConversingButton") {
//                    immersiveEntity.addChild(sceneAttachment1)
//                    sceneAttachment1.position += SIMD3(0, 0.2, 0)
//                }
//                
//                if let sceneAttachment2 = attachments.entity(for: "DisplayResponse") {
//                    immersiveEntity.addChild(sceneAttachment2)
//                    sceneAttachment2.position += SIMD3(0, 0.7, 0)
//                }
//                
//            } catch {
//                print("Error in RealityView's make: \(error)")
//            }
//        } update: { content, _ in
//            // Update the RealityKit content when SwiftUI state changes
//        } attachments: {
//            // Attachment 1
//            Attachment(id: "StartConversingButton") {
//                Button("Start Conversing") {
//                    speechRecognizer.startTranscribing()
//                }
//                .padding()
//                .glassBackgroundEffect()
//            }
//            
//            // Attachment 2
//            Attachment(id: "DisplayResponse") {
//                Text("Response:")
//                    .foregroundColor(.white) // Set text color to white
//                ForEach(storedResponses, id: \.self) { response in
//                    Text(response)
//                        .foregroundColor(.white) // Set text color to white
//                        .background(Color.black)
//                }
//            }
//            
////            // Attachment 2
////            Attachment(id: "DisplayResponse") {
////                Text("Response:")
////                    .foregroundColor(.white) // Set text color to white
////                ForEach($storedResponses, id: \.self) { $response in
////                    Text(response)
////                        .foregroundColor(.white) // Set text color to white
////                }
////            }
//        
//        }
////        .onChange(of: storedResponses) { newValue, oldValue in
////            DispatchQueue.main.async {
////                // Force view update when storedResponses changes
////                print("\nSTORED RESPONSES UPDATE UI: \(storedResponses) \n")
////            }
////        }
//        .onChange(of: storedResponses) { newValue in
//            // Force UI update when storedResponses changes
//            // This closure will be executed whenever storedResponses changes
//        }
//        .onAppear {
//            startFetchingData()
//        }
//        .gesture(TapGesture()
//            .targetedToAnyEntity()
//            .onEnded({ value in print("Tapped work \(value.entity)")
//                if !upAnimation{
//                    //move the water drop upward after tap gesture
//                    particles.isEmitting = false
//                    value.entity.components.remove(ParticleEmitterComponent.self)
//                    value.entity.components[ParticleEmitterComponent.self] = pSystem()
//                    var transform = value.entity.transform
//                    transform.translation += SIMD3(0.70, -0.15, -1)
//                    let radians = -30 * Float.pi / 180
//                    transform.rotation = simd_quatf(angle: radians, axis: SIMD3<Float>(0,1,0))
//                    value.entity.move(to: transform, relativeTo: nil, duration: 1, timingFunction: .easeInOut)
//                    if(transform.translation.y > 0.3){
//                        upAnimation = true
//                        downAnimation = false
//                    }
//                    print("first")
//                } else if !downAnimation {
//                    //move the water drop downward after tap gesture
//                    particles.isEmitting = false
//                    value.entity.components.remove(ParticleEmitterComponent.self)
//                    value.entity.components[ParticleEmitterComponent.self] = pSystem()
//                    var transform = value.entity.transform
//                    transform.translation += SIMD3(0.70, -0.55, -1)
//                    let radians = -30 * Float.pi / 180
//                    transform.rotation = simd_quatf(angle: radians, axis: SIMD3<Float>(0,1,0))
//                    value.entity.move(to: transform, relativeTo: nil, duration: 1, timingFunction: .easeInOut)
//                    if(transform.translation.y < -0.3){
//                        upAnimation = false
//                        downAnimation = true
//                    }
//                    print("second")
//                }
//            })
//        )
//    }
//
//
//    //WaterDrop firework particles
//    func pSystem() -> ParticleEmitterComponent {
//        particles.emitterShape = .sphere
//        particles.burstCount = 100
//        particles.burst()
//        return particles
//    }
//
//    //Avatar looking at user
//    static func rotateEntityAroundYAxis(entity: Entity, angle: Float){
//        var currentTransform = entity.transform
//        let rotation = simd_quatf(angle: angle, axis: [0, 1, 0])
//        currentTransform.rotation = rotation * currentTransform.rotation
//        entity.transform = currentTransform
//    }
//    
//    // Schedule fetching data every X seconds
//    func startFetchingData() {
//        print("\nstartFetchingData() RUNS...\n")
//        Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { _ in
//            fetchDataFromAPI()
//        }
//    }
//    
////    // Fetch data from ChatGPT's response to display in frontend
////    func fetchDataFromAPI() {
////        print("\nfetchDataFromAPI() RUNS...\n")
////        OpenAIService.shared.fetchResponseFromChatGPT(dataString: "") { result in
////            switch result {
////            case .success(let dataString):
////                print("Data fetched successfully.")
////                DispatchQueue.main.async {
////                    storedResponses.removeAll() // Clear the stored responses before appending new data
////                    storedResponses.removeAll { $0.isEmpty } // Remove empty strings
////                    storedResponses.append(dataString) // Update stored responses
////                }
////            case .failure(let error):
////                print("Error fetching data:", error.localizedDescription)
////            }
////        }
////    }
//  
//    // Fetch data from ChatGPT's response to display in frontend
//    func fetchDataFromAPI() {
//        print("Fetching data from ChatGPT API IN FRONTEND...")
//        OpenAIService.shared.fetchResponseFromChatGPT(dataString: "") { result in
//            switch result {
//            case .success(let dataString):
//                print("Data fetched successfully.")
//                
//                // Replace storedResponses with the latest value
//                storedResponses = [dataString]
//                
//            case .failure(let error):
//                print("Error fetching data:", error.localizedDescription)
//            }
//        }
//    }
//
//}
//
//#Preview {
//    WaterView()
//}





//import SwiftUI
//import RealityKit
//import RealityKitContent
//
//struct WaterView: View {
//    @State public var upAnimation = false
//    @State public var downAnimation = true
//    @State var particles = ParticleEmitterComponent()
//
//    @StateObject var speechRecognizer = SpeechRecognizer()
//    
//    @State private var receivedData: String = ""
//    
//    @StateObject var responseViewModel = ResponseViewModel()
//    
//    
//    
//    let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
//    @State private var count:Int = 1
//
//    @State private var waterDrop: Entity? = nil
//    @State var characterEntity: Entity = {
//        let headAnchor = AnchorEntity(.head)
//        headAnchor.position = [0.70, -0.35, -1]
//        let radians = -30 * Float.pi / 180
//        WaterView.rotateEntityAroundYAxis(entity: headAnchor, angle: radians)
//        return headAnchor
//    }()
//
//    var body: some View {
//        RealityView { content, attachments in
//            // Add the initial RealityKit content
//            do {
//                let immersiveEntity = try await Entity(named: "Immersive", in: realityKitContentBundle)
//                characterEntity.addChild(immersiveEntity)
//                content.add(characterEntity)
//                
//                if let sceneAttachment1 = attachments.entity(for: "StartConversingButton") {
//                    immersiveEntity.addChild(sceneAttachment1)
//                    sceneAttachment1.position += SIMD3(0, 0.2, 0)
//                }
//                
//                if let sceneAttachment2 = attachments.entity(for: "DisplayResponse") {
//                    immersiveEntity.addChild(sceneAttachment2)
//                    sceneAttachment2.position += SIMD3(0, 0.5, 0)
//                }
//                
//            } catch {
//                print("Error in RealityView's make: \(error)")
//            }
//        } update: { content, _ in
//            // Update the RealityKit content when SwiftUI state changes
//        } attachments: {
//            // Attachment 1
//            Attachment(id: "StartConversingButton") {
//                Button("Start Conversing") {
//                    speechRecognizer.startTranscribing()
//                }
//                .padding()
//                .glassBackgroundEffect()
//            }
//            
//            // Attachment 2
//            Attachment(id: "DisplayResponse") {
//                Text("Response:")
//                Text(responseViewModel.receivedContent)
//            }
//        }
////        .onReceive(timer) { _ in
////            // Update the view model to trigger text refresh
////            responseViewModel.updateContent("Updated Content")
////        }
//        .onReceive(timer) { _ in
//            // Assuming you have a way to fetch real-time content and store it in a variable called "realTimeContent"
//            var realTimeContent: String? // Define realTimeContent as optional
//
//            // Logic to fetch real-time content and store it in realTimeContent
//            // For example, if you fetch it from an API response, you might do something like:
//            // realTimeContent = apiResponse.content
//
//            // Check if realTimeContent is not nil before updating the view model
//            if let content = realTimeContent {
//                responseViewModel.updateContent(content)
//            }
//        }
//        .onAppear {
//            // Start the timer when the view appears
//            timer 
//        }
//        .gesture(TapGesture()
//            .targetedToAnyEntity()
//            .onEnded({ value in print("Tapped work \(value.entity)")
//                if !upAnimation{
//                    //move the water drop upward after tap gesture
//                    particles.isEmitting = false
//                    value.entity.components.remove(ParticleEmitterComponent.self)
//                    value.entity.components[ParticleEmitterComponent.self] = pSystem()
//                    var transform = value.entity.transform
//                    transform.translation += SIMD3(0.70, -0.15, -1)
//                    let radians = -30 * Float.pi / 180
//                    transform.rotation = simd_quatf(angle: radians, axis: SIMD3<Float>(0,1,0))
//                    value.entity.move(to: transform, relativeTo: nil, duration: 1, timingFunction: .easeInOut)
//                    if(transform.translation.y > 0.3){
//                        upAnimation = true
//                        downAnimation = false
//                    }
//                    print("first")
//                } else if !downAnimation {
//                    //move the water drop downward after tap gesture
//                    particles.isEmitting = false
//                    value.entity.components.remove(ParticleEmitterComponent.self)
//                    value.entity.components[ParticleEmitterComponent.self] = pSystem()
//                    var transform = value.entity.transform
//                    transform.translation += SIMD3(0.70, -0.55, -1)
//                    let radians = -30 * Float.pi / 180
//                    transform.rotation = simd_quatf(angle: radians, axis: SIMD3<Float>(0,1,0))
//                    value.entity.move(to: transform, relativeTo: nil, duration: 1, timingFunction: .easeInOut)
//                    if(transform.translation.y < -0.3){
//                        upAnimation = false
//                        downAnimation = true
//                    }
//                    print("second")
//                }
//            })
//        )
//    }
//
//
//    //WaterDrop firework particles
//    func pSystem() -> ParticleEmitterComponent {
//        particles.emitterShape = .sphere
//        particles.burstCount = 100
//        particles.burst()
//        return particles
//    }
//
//    //Avatar looking at user
//    static func rotateEntityAroundYAxis(entity: Entity, angle: Float){
//        var currentTransform = entity.transform
//        let rotation = simd_quatf(angle: angle, axis: [0, 1, 0])
//        currentTransform.rotation = rotation * currentTransform.rotation
//        entity.transform = currentTransform
//    }
//    
////    // Fetch data from ChatGPT's response to display in frontend
////    func fetchDataFromAPI() {
////        print("Fetching data from ChatGPT API IN FRONTEND...")
////        OpenAIService.shared.fetchResponseFromChatGPT(dataString: "") { result in
////            switch result {
////            case .success(let dataString):
////                print("Data fetched successfully.")
////                DispatchQueue.main.async {
////                    receivedData = dataString
////                }
////            case .failure(let error):
////                print("Error fetching data:", error.localizedDescription)
////            }
////        }
////    }
//
//}
//
//#Preview {
//    WaterView()
//}





import SwiftUI
import RealityKit
import RealityKitContent

struct WaterView: View {
    @State public var upAnimation = false
    @State public var downAnimation = true
    @State var particles = ParticleEmitterComponent()

    @StateObject var speechRecognizer = SpeechRecognizer()
    
    @State private var receivedData: String = ""
    
//    @StateObject var responseViewModel = ResponseViewModel()
//    @ObservedObject var responseViewModel = ResponseViewModel()
    
    @State var globalVariable: String = ""
//    @State var globalVariable = [String]()
    
//    @StateObject var openaiservice = OpenAIService()
    private let openaiservice = OpenAIService()
    
    
    
    let timer = Timer.publish(every: 10.0, on: .main, in: .common).autoconnect()
//    let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    @State private var count:Int = 1

    @State private var waterDrop: Entity? = nil
//    @State var characterEntity: Entity = {
//        let headAnchor = AnchorEntity(.head)
//        headAnchor.position = [0.70, -0.35, -1]
//        let radians = -30 * Float.pi / 180
//        WaterView.rotateEntityAroundYAxis(entity: headAnchor, angle: radians)
//        return headAnchor
//    }()
    
    
    //var fred: Entity?
    
    var body: some View {
        RealityView { content, attachments in
            // Add the initial RealityKit content
            do {
                let immersiveEntity = try await Entity(named: "Immersive", in: realityKitContentBundle)
//                characterEntity.addChild(immersiveEntity)
//                fred = immersiveEntity.children.first(where: { each in
//                    each.name == "FFF"
//                })
                
                content.add(immersiveEntity)
            } catch {
                print("Error in RealityView's make: \(error)")
            }
        } update: { content, _ in
            // Update the RealityKit content when SwiftUI state changes
        } attachments: {
            // Attachment 1
            Attachment(id: "StartConversingButton") {
                Button("Start Conversing") {
                    speechRecognizer.startTranscribing()
                }
                .padding()
                .glassBackgroundEffect()
            }
            
//            // Attachment 2
//            Attachment(id: "DisplayResponse") {
//                Text("Response:")
//                Text(responseViewModel.receivedContent)
//            }
            
//            // Attachment 2
//            Attachment(id: "DisplayResponse") {
//                Text("Response:")
//                Text(responseViewModel.receivedContent)
//                    .onChange(of: responseViewModel.receivedContent) { newValue in
//                        print("\nRECEIVED CONTENT UPDATED:", newValue)
//                    }
//            }
            
            // Attachment 2
            Attachment(id: "DisplayResponse") {
                Text("Response:")
                Text(globalVariable)
            }
        }
//        .onReceive(timer) { _ in
//            // Update the view model to trigger text refresh
//            print("Timer received")
//            print("Current content in responseViewModel:", responseViewModel.receivedContent)
//            responseViewModel.updateContent(responseViewModel.receivedContent)
//        }
        .onReceive(timer) { _ in // Observe changes to savedContent
//            fetchDataFromAPI()
            globalVariable.append(GlobalVariables.dataString)
            
            print("(FRONTEND) Timer received")
            print("(FRONTEND) Current content in responseViewModel:", globalVariable)
        }
//        .onReceive(timer) { _ in
//            appendToGlobal()
//
//            // Update the view model to trigger text refresh
//            print("Timer received")
//            print("Current content in responseViewModel:", globalVariable)
////            responseViewModel.updateContent(responseViewModel.receivedContent)
//        }
        .onAppear {
            // Start the timer when the view appears
            timer
        }
        .gesture(TapGesture()
            .targetedToAnyEntity()
            .onEnded({ value in print("Tapped work \(value.entity)")
                if !upAnimation{
                    //move the water drop upward after tap gesture
                    particles.isEmitting = false
                    value.entity.components.remove(ParticleEmitterComponent.self)
                    value.entity.components[ParticleEmitterComponent.self] = pSystem()
                    var transform = value.entity.transform
                    transform.translation += SIMD3(0, 0.2, 0)
//                    transform.translation = SIMD3(0.1, 0, 0)
//                    let radians = -30 * Float.pi / 180
//                    transform.rotation = simd_quatf(angle: radians, axis: SIMD3<Float>(0,1,0))
                    value.entity.move(to: transform, relativeTo: nil, duration: 1, timingFunction: .easeInOut)
                    if(transform.translation.y > 1.51){
                        upAnimation = true
                        downAnimation = false
                    }
                    print("first")
                } else if !downAnimation {
                    //move the water drop downward after tap gesture
                    particles.isEmitting = false
                    value.entity.components.remove(ParticleEmitterComponent.self)
                    value.entity.components[ParticleEmitterComponent.self] = pSystem()
                    var transform = value.entity.transform
                    transform.translation += SIMD3(0, -0.2, 0)
//                    transform.translation = SIMD3(-0.1, 0, 0)
//                    let radians = -30 * Float.pi / 180
//                    transform.rotation = simd_quatf(angle: radians, axis: SIMD3<Float>(0,1,0))
                    value.entity.move(to: transform, relativeTo: nil, duration: 1, timingFunction: .easeInOut)
                    if(transform.translation.y < 1.49){
                        upAnimation = false
                        downAnimation = true
                    }
                    print("second")
                }
            })
        )
    }


    //WaterDrop firework particles
    func pSystem() -> ParticleEmitterComponent {
        particles.emitterShape = .sphere
        particles.burstCount = 100
        particles.burst()
        return particles
    }

//    //Avatar looking at user
//    static func rotateEntityAroundYAxis(entity: Entity, angle: Float){
//        var currentTransform = entity.transform
//        let rotation = simd_quatf(angle: angle, axis: [0, 1, 0])
//        currentTransform.rotation = rotation * currentTransform.rotation
//        entity.transform = currentTransform
//        }
}

#Preview {
    WaterView()
}
