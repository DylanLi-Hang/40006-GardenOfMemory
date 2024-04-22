//
//  TestView.swift
//  Garden_Of_Memory
//
//  Created by Dylan on 2/4/2024.
//

import SwiftUI
import SwiftData

struct ConversationView: View {
    var chatEntry: ChatEntry
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text("Date: \(chatEntry.date, formatter: dateFormatter)")
                Text("Mood: \(chatEntry.mood)")
                Text("Name: \(chatEntry.name ?? "No Name")")
                
//                Text("Messages:")
//                ForEach(chatEntry.messages.indices, id: \.self) { index in
//                    ForEach(chatEntry.messages[index].keys.sorted(), id: \.self) { key in
//                        Text("    \(key): \(chatEntry.messages[index][key] ?? "")")
//                    }
//                }
                
                ForEach(chatEntry.chatMessages) { chatMessage in
                    if chatMessage.role != .system {
                        Text("    \(chatMessage.role.rawValue): \(chatMessage.content ?? "")")
                    }
                }
                
                Text("Tags:")
                ForEach(chatEntry.tags, id: \.self) { tag in
                    Text("    " + tag)
                }
            }
            .padding(80)
        }
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        ConversationView(chatEntry: generateDummyChat())
    }
    
    static func generateDummyChat() -> ChatEntry {
        let date = Date()
        let mood = Int.random(in: 1...10)
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
