//
//  ConversationTagsRetrieval.swift
//  Garden_Of_Memory
//
//  Created by Grace on 7/5/2024.
//

import Foundation
import OpenAIKit
import SwiftUI
import GoogleGenerativeAI

class ConversationTagsViewModel: ObservableObject {
    
    var tagsPrompt: [ChatMessage] = [] // Used for sending prompt to chatgpt asking to rate user's mood from a scale of 1-5
    
    @Published var tags: [ChatMessage] = []
    
    var openAI: OpenAI
    var gemini: GenerativeModel
    
    var responseText: String = ""
    
    // Initilaise another open ai, for your emotion tag retrieval
    init() {
        let config = Configuration(
            organizationId: "",
            apiKey: APIKey.openai
        )
        let geminiConfig = GenerationConfig(
            temperature: 0.1,
            maxOutputTokens: 2048
        )
        self.openAI = OpenAI(config)
        self.gemini = GenerativeModel(name: "gemini-1.0-pro", apiKey: APIKey.default, generationConfig: geminiConfig)
        
        self.tagsPrompt.append(ChatMessage(role: .system, content: Prompt.tagsInitPrompt))
    }
    
    func retrieveConversationTags(_ latestFourUserMessagesContent: [String], completion: @escaping ([String]?, Error?) -> Void) {
        let latestFourConversations = latestFourUserMessagesContent.joined(separator: "\n")
        self.tagsPrompt.append(ChatMessage(role: .user, content: latestFourConversations))
        
        Task {
            do {
                let result = try await openAI.generateChatCompletion(parameters: ChatParameters(model: .chatGPTTurbo, messages: self.tagsPrompt))
//                let result = try await gemini.generateContent(Prompt.tagsInitPrompt + latestFourConversations)
                var tags = [String]()
                
                guard let choice = result.choices.first else { return }
                if let message = choice.message, let content = message.content {
                    if let startIndex = content.range(of: "{"), let endIndex = content.range(of: "}") {
                        let tagSubstring = content[startIndex.upperBound..<endIndex.lowerBound]
                        let components = tagSubstring.components(separatedBy: ":")
                        if components.count >= 2 {
                            let word = components[1].trimmingCharacters(in: .whitespaces)
                                .replacingOccurrences(of: "\"", with: "")
                                .replacingOccurrences(of: "'", with: "")
                            tags.append(word)
                        } else {
                            completion(nil, nil)
                            return
                        }
                    }
                }
                
                completion(tags, nil)
            } catch {
                completion(nil, error)
            }
        }
    }
    
}
