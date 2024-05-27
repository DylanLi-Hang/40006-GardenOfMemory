//
//  TerrariumGirdView.swift
//  Garden_Of_Memory
//
//  Created by Denni O on 5/27/24.
//

import SwiftUI
import SwiftData
import RealityKit
import RealityKitContent

struct TerrariumGridView: View {
    @Environment(\.modelContext) private var modelContext
    @Query var chats: [ChatEntry]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(chats) { chat in
                        NavigationLink(destination: ConversationView(chatEntry: chat)) {
                            VStack {
                                Model3D(named: terrariumModelName(for: chat.mood), bundle: realityKitContentBundle, content: { modelPhase in
                                    switch modelPhase {
                                    case .empty:
                                        ProgressView()
                                            .controlSize(.large)
                                    case .success(let resolvedModel3D):
                                        resolvedModel3D
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .scaleEffect(0.3)
                                    case .failure(let error):
                                        Text("Fail")
                                    }
                                })
                                .frame(width: 100, height: 100)
                                Text("\(chat.getStringDate())")
                                    .font(.title) // Increased font size for the date
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10)
                                            .fill(Color(.systemGray6)))
                            .shadow(radius: 5)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Terrarium Record")
    }

    private func terrariumModelName(for mood: Int) -> String {
        switch mood {
        case 1:
            return "TerrariumThunderScene" // Replace with your actual image names
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

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

#Preview {
    let preview = PreviewContainer([ChatEntry.self])
    
    var chats = [generateDummyChat(), generateDummyChat()]
    preview.add(items: chats)
                                                         
    return NavigationStack {
        TerrariumGridView()
            .modelContainer(preview.container)
    }
}
