//
//  DisplayConversationView.swift
//  Garden_Of_Memory
//
//  Created by Dylan on 2/4/2024.
//

import SwiftUI
import SwiftData

struct ListConversationView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query var chats: [ChatEntry]
    
    let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter
        }()
    
    var body: some View {
        NavigationSplitView {
            List {
                NavigationLink {
                    TestInsertDummyView()
                } label: {
                    Text("Insert Data")
                }
                
                ForEach(chats) { chat in
                    NavigationLink {
                        ConversationView(chatEntry: chat)
                    } label: {
                        Text(chat.getStringDate() + " " + (chat.name ?? "No Name"))
                    }
                    .swipeActions {
                        Button("Delete", role: .destructive) {
                            modelContext.delete(chat)
                        }
                    }
                }
            }
        } detail: {
            Text("View")
        }
    }
}

#Preview {
    let preview = PreviewContainer([ChatEntry.self])
    
    var chats = [generateDummyChat(), generateDummyChat()]
    preview.add(items: chats)
                                                         
    
    return NavigationStack {
        ListConversationView()
            .modelContainer(preview.container)
    }
}
