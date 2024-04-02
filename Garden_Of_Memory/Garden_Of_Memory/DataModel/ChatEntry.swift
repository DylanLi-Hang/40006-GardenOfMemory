//
//  Conversation.swift
//  Garden_Of_Memory
//
//  Created by Dylan on 2/4/2024.
//

/*
 Variables:
    - date: Date
    - mood: Int
    - messages: [Dict]
    - tags: [String]
 Functions:
    - Read the conversation (get messages)
    - Append New Chat (role: str, content: str)
 */
import Foundation
import SwiftData

@Model
class ChatEntry {
    var date: Date
    var name: String?
    var mood: Int // Scale 1 - 10
    var messages: [[String: String]]
    var tags: [String]
    
    init(date: Date, mood: Int, messages: [[String: String]], tags: [String], name: String?) {
        self.date = date
        self.mood = mood
        self.messages = messages
        self.tags = tags
        self.name = name
    }
    
    func getStringDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        return dateFormatter.string(from: self.date)
    }
}

func generateDummyChat() -> ChatEntry {
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
