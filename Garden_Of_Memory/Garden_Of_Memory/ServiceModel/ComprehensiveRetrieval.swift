//
//  ComprehensiveRetrieval.swift
//  Garden_Of_Memory
//
//  Created by Grace on 23/5/2024.
//

import Foundation
import Foundation
import OpenAIKit
import SwiftUI
import GoogleGenerativeAI

struct MoodEntry: Decodable {
    let mood: Int
    let tags: [String]
    let summarization: String
}

class ComprehensiveViewModel: ObservableObject {
    
    @Published var moodEntry: MoodEntry?
    var chatPrompts: [ChatMessage] = []
    
    var gemini: GenerativeModel
    
    init() {
        let config = Configuration(
            organizationId: "",
            apiKey: APIKey.openai
        )
        let geminiConfig = GenerationConfig(
            temperature: 0.1,
            maxOutputTokens: 2048
        )
        
        self.gemini = GenerativeModel(name: "gemini-1.0-pro", apiKey: APIKey.default, generationConfig: geminiConfig)
    }
    
    func analyzeChat(_ latestUserMessagesContent: [String], completion: @escaping (MoodEntry?, Error?) -> Void) {
        let latestConversations = latestUserMessagesContent.joined(separator: "\n")
        self.chatPrompts.append(ChatMessage(role: .user, content: latestConversations))
        
        Task {
            do {
                let response = try await self.gemini.generateContent(Prompt.comprehensivePrompt + latestConversations)
                if let text = response.text {
                    print(text)
                    extractAndParseJson(from: text, completion: completion)
                }
            } catch {
                completion(nil, error)
            }
        }
    }
    
    private func extractAndParseJson(from text: String, completion: (MoodEntry?, Error?) -> Void) {
        let pattern = "```json\\n(.*?)\\n```"
        let regex = try? NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators])
        
        if let regex = regex {
            let nsrange = NSRange(text.startIndex..<text.endIndex, in: text)
            if let match = regex.firstMatch(in: text, options: [], range: nsrange) {
                if let range = Range(match.range(at: 1), in: text) {
                    let extractedText = text[range]
                    print(extractedText)
                    guard let jsonData = extractedText.data(using: .utf8) else {
                        completion(nil, NSError(domain: "ViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON string"]))
                        return
                    }
                    
                    let decoder = JSONDecoder()
                    
                    do {
                        let moodEntry = try decoder.decode(MoodEntry.self, from: jsonData)
                        completion(moodEntry, nil)
                    } catch {
                        completion(nil, error)
                    }
                }
            }
        } else {
            completion(nil, NSError(domain: "ViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "No JSON format found"]))
        }
    }
}
