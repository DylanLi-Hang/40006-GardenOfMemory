//
//  ConversationTagsRetrieval.swift
//  Garden_Of_Memory
//
//  Created by Grace on 7/5/2024.
//

import Foundation
import OpenAIKit
import SwiftUI

class ConversationTagsViewModel: ObservableObject {
    
    var tagsPrompt: [ChatMessage] = [] // Used for sending prompt to chatgpt asking to rate user's mood from a scale of 1-5
    
    @Published var tags: [ChatMessage] = []
    
    var openAI: OpenAI
    
    var responseText: String = ""
    
    // Initilaise another open ai, for your emotion tag retrieval
    init() {
        let config = Configuration(
            organizationId: "",
            apiKey: APIKey.openai
        )
        self.openAI = OpenAI(config)
        
        self.tagsPrompt.append(ChatMessage(role: .system, content: Prompt.tagsInitPrompt))
    }
    
    func retrieveConversationTags(_ latestFourUserMessagesContent: [String]) {
        let latestFourConversations = latestFourUserMessagesContent.joined(separator: "\n")

        self.tagsPrompt.append(ChatMessage(role: .user, content: latestFourConversations))
        
        do {
            // Perform the asynchronous operation
            Task {
                do {
                    let result = try await openAI.generateChatCompletion(parameters: ChatParameters(model: .chatGPTTurbo, messages: self.tagsPrompt))
                    
                    // Process the result synchronously
                    for choice in result.choices {
                        
                        if let message = choice.message, let content = message.content {
                            
                            // Find the index of the opening and closing curly braces
                            if let startIndex = content.range(of: "{"), let endIndex = content.range(of: "}") {
                                // Extract the substring containing the mood value
                                let tagSubstring = content[startIndex.upperBound..<endIndex.lowerBound]
 
                                // Split the substring at the colon
                                let components = tagSubstring.components(separatedBy: ":")
                                if components.count >= 2 {
                                    // Extract the second component (the word), trimming whitespace
                                    let word = components[1].trimmingCharacters(in: .whitespaces).replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: "'", with: "")
                                    print("Conversation Tag:", word)
                                    // Use the word value as needed
                                } else {
                                    print("Invalid tag substring format")
                                }
                            }
                        }
                    }
                } catch {
                    print("Error processing text: \(error)")
                }
                
                // Add a delay before checking for response again
                await Task.sleep(500) // Sleep for 500 milliseconds (adjust as needed)
            }
        } catch {
            print("Error processing text: \(error)")
        }
        
    }
    
}
