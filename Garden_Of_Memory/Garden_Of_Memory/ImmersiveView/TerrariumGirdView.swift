//
//  TerrariumGirdView.swift
//  Garden_Of_Memory
//
//  Created by Denni O on 5/27/24.
//

import SwiftUI
import SwiftData

struct TerrariumGridView: View {
    @Environment(\.modelContext) private var modelContext
    @Query var chats: [ChatEntry]

    @State private var showDeleteConfirmation = false
    @State private var chatToDelete: ChatEntry?

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(chats) { chat in
                            VStack {
                                NavigationLink(destination: ConversationView(chatEntry: chat)) {
                                    VStack {
                                        Image(terrariumImageName(for: chat.mood)) // Displaying the terrarium image
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 100, height: 100)
                                        Text("\(chat.getStringDate())")
                                            .font(.title) // Increased font size for the date
                                    }
                                    .padding()
                                    .background(RoundedRectangle(cornerRadius: 10)
                                                    .fill(Color(.systemGray6)))
                                    .shadow(radius: 5)
                                }
                                .buttonStyle(PlainButtonStyle()) // Apply PlainButtonStyle to remove default button styling
                                .contextMenu {
                                    Button(role: .destructive) {
                                        chatToDelete = chat
                                        showDeleteConfirmation = true
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                            .buttonStyle(PlainButtonStyle()) // Apply PlainButtonStyle to remove default button styling
                            .contextMenu {
                                Button(role: .destructive) {
                                    modelContext.delete(chat)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Terrarium Record")
            .alert("Delete Entry", isPresented: $showDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    if let chatToDelete = chatToDelete {
                        modelContext.delete(chatToDelete)
                        self.chatToDelete = nil
                    }
                }
                Button("Cancel", role: .cancel) {
                    self.chatToDelete = nil
                }
            } message: {
                Text("Are you sure you want to delete this entry?")
            }
        }
    }

    private func terrariumImageName(for mood: Int) -> String {
        switch mood {
        case 1:
            return "Thunderstorm" // Replace with your actual image names
        case 2:
            return "Rainy"
        case 3:
            return "Cloudy"
        case 4:
            return "Sunny"
        case 5:
            return "Rainbow"
        default:
            return "Sunny" // Default scene
        }
    }

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

struct TerrariumGridView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleChats = (1...8).map { _ in
            generateDummyChat()
        }
        let previewContainer = PreviewContainer([ChatEntry.self])
        previewContainer.add(items: sampleChats)

        return NavigationStack {
            TerrariumGridView()
                .modelContainer(previewContainer.container)
        }
    }
}
