//
//  EmotionScaleRetrieval.swift
//  Garden_Of_Memory
//
//  Created by Grace on 7/5/2024.
//

import Foundation
import OpenAIKit
import SwiftUI

class EmotionScaleViewModel: ObservableObject {
    
    var moodPrompt: [ChatMessage] = [] // Used for sending prompt to chatgpt asking to rate user's mood from a scale of 1-5
    @Published var mood: Int = 0 // Used for receiving the mood value from chatgpt's response
        
    var openAI: OpenAI
    
    var responseText: String = ""
    
    // Initilaise another open ai, for your emotion tag retrieval
    init() {
        let config = Configuration(
            organizationId: "",
            apiKey: APIKey.openai
        )
        self.openAI = OpenAI(config)
                
        self.moodPrompt.append(ChatMessage(role: .system, content: Prompt.emotionScaleInitPrompt))
    }
    
    func retrieveEmotionScale(_ latestFourUserMessagesContent: [String]) {
        let latestFourConversations = latestFourUserMessagesContent.joined(separator: "\n")
        
        self.moodPrompt.append(ChatMessage(role: .user, content: latestFourConversations))
        
        do {
            // Perform the asynchronous operation
            Task {
                do {
                    let result = try await openAI.generateChatCompletion(parameters: ChatParameters(model: .chatGPTTurbo, messages: self.moodPrompt))
                    
                    // Process the result synchronously
                    for choice in result.choices {
                        
                        if let message = choice.message, let content = message.content {
                            // Find the index of the opening and closing curly braces
                            if let startIndex = content.range(of: "{"), let endIndex = content.range(of: "}") {
                                // Extract the substring containing the mood value
                                let moodSubstring = content[startIndex.upperBound..<endIndex.lowerBound]
                                
                                // Trim whitespace and remove any non-numeric characters
                                let trimmedMoodString = moodSubstring.trimmingCharacters(in: .whitespaces).filter { "0123456789".contains($0) }
                                
                                // Convert the trimmed mood string to an integer
                                if let mood = Int(trimmedMoodString) {
                                    print("Mood:", mood)
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
