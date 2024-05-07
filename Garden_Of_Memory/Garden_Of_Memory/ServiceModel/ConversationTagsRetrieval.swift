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
        print("\n\nIN EMOTION SCALE RETRIEVAL FILE:\n", latestFourUserMessagesContent, "\n\n")
        
        self.tagsPrompt.append(ChatMessage(role: .user, content: latestFourConversations))
        print("\n\n(IN EMOTION SCALE RETRIEVAL FILE) self.moodPrompt:\n", self.tagsPrompt, "\n\n")
        
        do {
            // Perform the asynchronous operation
            Task {
                do {
                    let result = try await openAI.generateChatCompletion(parameters: ChatParameters(model: .chatGPTTurbo, messages: self.tagsPrompt))
                    // print("\n\n(IN EMOTION SCALE RETRIEVAL FILE) result:\n", result, "\n\n")
                    
                    // Process the result synchronously
                    for choice in result.choices {
                        // print("\n\n(IN EMOTION SCALE RETRIEVAL FILE) choice:", choice, "\n\n")
                        
                        if let message = choice.message, let content = message.content {
                            // Access the content of the ChatMessage
                            // print("\n\nContent:", content, "\n\n")
                            
                            // Find the index of the opening and closing curly braces
                            if let startIndex = content.range(of: "{"), let endIndex = content.range(of: "}") {
                                // Extract the substring containing the mood value
                                let tagSubstring = content[startIndex.upperBound..<endIndex.lowerBound]
                                
                                // Trim whitespace and remove any non-numeric characters
                                let trimmedConversationTagString = tagSubstring.trimmingCharacters(in: .whitespaces).filter { "0123456789".contains($0) }
                                
                                // Convert the trimmed mood string to an integer
                                if let tag = Int(trimmedConversationTagString) {
                                    print("Conversation Tag:", tag)
                                    // Use the mood value as needed
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
