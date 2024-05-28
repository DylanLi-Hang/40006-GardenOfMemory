//
//  TestView.swift
//  Garden_Of_Memory
//
//  Created by Dylan on 2/4/2024.
//

import SwiftUI
import SwiftData
import RealityKit
import RealityKitContent

struct ConversationView: View {
    @Environment(\.openImmersiveSpace) var openImmersiveTerrarium
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveTerrarium
    
    @State private var isImmersiveTerrariumViewOpen: Bool = false
    
    let viewModel = ViewModel.shared
    
    var chatEntry: ChatEntry
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        NavigationSplitView {
//            HStack{
//                //Back Button
//                Button {
//                    print("Return to diary menu")
//                } label: {
//                    Image(systemName: "chevron.backward")
//                }
//                .padding(0)
//                Spacer()
//            }
//            .navigationBarHidden(true)
            
            
            // Terrarium of the day
            Model3D(named: terrariumModelName(for: chatEntry.mood), bundle: realityKitContentBundle, content: { modelPhase in
                switch modelPhase {
                case .empty:
                    ProgressView()
                        .controlSize(.extraLarge)
                case .success(let resolvedModel3D):
                    resolvedModel3D
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .scaleEffect(0.3)
//                        .position(x: 1, y: 1)
                case .failure(let error):
                    Text("Fail")
                }
            })
            .onChange(of: viewModel.mood) { newMood in
                print("Mood changed to: \(newMood), updating terrarium model")
            }
            
            Spacer()
            
            // Button for immersive terrarium
            Button("Immersive Terrarium") {
                viewModel.terrarium.toggle()
                isImmersiveTerrariumViewOpen = viewModel.terrarium
                print(viewModel.terrarium)
            }
            .onChange(of: isImmersiveTerrariumViewOpen) { _, newValue in
                Task {
                    if newValue {
                        await openImmersiveTerrarium(id: "FullTerrarium")
                        let sceneName = terrariumModelName(for: viewModel.mood)
                        playAudioForScene(sceneName: sceneName)
                    } else {
                        await dismissImmersiveTerrarium()
                    }
                }
            }
            Spacer()
        } detail: {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
//                    Text("Title: \(chatEntry.name ?? "No Name")")
//                        .font(.extraLargeTitle)
                    Text("Date: \(chatEntry.date, formatter: dateFormatter)")
                        .font(.title)
                    Text("Mood: \(chatEntry.mood)")
                        .font(.title)
                    
                    //                Text("Messages:")
                    //                ForEach(chatEntry.messages.indices, id: \.self) { index in
                    //                    ForEach(chatEntry.messages[index].keys.sorted(), id: \.self) { key in
                    //                        Text("    \(key): \(chatEntry.messages[index][key] ?? "")")
                    //                    }
                    //                }
                    
                    Spacer()
                    
                    Text("Highlights of the Day: ")
                        .font(.title)
                    Text(chatEntry.summarization)
                    
                    Spacer()
                    
                    Text("Conversation: ")
                        .font(.title)
                    
                    
                    
                    
                    ForEach(chatEntry.chatMessages) { chatMessage in
                        if chatMessage.role != .system {
                            Text("    \(chatMessage.role.rawValue): \(chatMessage.content ?? "")")
                        }
                    }
                    
                    Text("Tags:")
                        .bold()
                    ForEach(chatEntry.tags, id: \.self) { tag in
                        Text("    " + tag)
                    }
                }
                .padding([.leading, .trailing], 80)
            }
            .navigationBarHidden(true)
        }
    }
    
    private func terrariumModelName(for mood: Int) -> String {
        switch mood {
        case 1:
            return "TerrariumThunderScene"
        case 2:
            return "TerrariumRainScene"
        case 3:
            return "TerrariumCloudScene"
        case 4:
            return "TerrariumSunnyScene"
        case 5:
            return "TerrariumRainbowScene"
        default:
            return "TerrariumSunnyScene" // Default scene
        }
    }
    
    private func playAudioForScene(sceneName: String) {
        let audioFileName: String
        switch sceneName {
            case "TerrariumThunderScene":
                audioFileName = "Thunder.mp3"
            case "TerrariumRainScene":
                audioFileName = "Rain.mp3"
            case "TerrariumCloudScene":
                audioFileName = "Cloud.mp3"
            case "TerrariumSunnyScene":
                audioFileName = "Sunny.mp3"
            case "TerrariumRainbowScene":
                audioFileName = "Rainbow.mp3"
            default:
                audioFileName = "Sunny.mp3"
        }

        print("Attempting to play audio named: \(audioFileName)")
        AudioManager.shared.playAudio(named: audioFileName)
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        ConversationView(chatEntry: generateDummyChat())
    }
    
    static func generateDummyChat() -> ChatEntry {
        let date = Date()
        let mood = Int.random(in: 1...5)
        let messages: [[String: String]] = [
            ["role": "system", "content": "You are a helpful assistant."],
            ["role": "user", "content": "What's the weather like today?"],
            ["role": "assistant", "content": "The weather today is sunny with a high of 25°C."],
            ["role": "user", "content": "Is it a good day for a picnic?"],
            ["role": "assistant", "content": "Yes, it's a perfect day for a picnic! Enjoy the nice weather."]
        ]
        let tags = ["weather", "outdoor activities"]
        
        func generateRandomString(length: Int) -> String {
            let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 "
            return String((0..<length).map{ _ in characters.randomElement()! })
        }
        
        return ChatEntry(date: date, mood: mood, messages: messages, tags: tags, name: generateRandomString(length: 10))
    }
}
