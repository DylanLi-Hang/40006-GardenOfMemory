//
//  DisplayConversationView.swift
//  Garden_Of_Memory
//
//  Created by Dylan on 2/4/2024.
//

import SwiftUI
import SwiftData

struct DisplayConversationView: View {
    let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter
        }()
    
    @Query var chats: [ChatEntry]
    
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
                        TestView(chatEntry: chat)
                    } label: {
                        Text(chat.getStringDate() + " " + (chat.name ?? "No Name"))
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
        DisplayConversationView()
            .modelContainer(preview.container)
    }
}
