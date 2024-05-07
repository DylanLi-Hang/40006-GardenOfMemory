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
                
        self.moodPrompt.append(ChatMessage(role: .system, content: Prompt.emotionScaleInitPrompt))
        
        self.tags.append(ChatMessage(role: .system, content: Prompt.tagsInitPrompt))
    }
    
    
    // next work on sending 4 conversations to chatgpt, and retrieving the mood scale, and store it in the "mood" variable".
    // end after completing the above, drink milo, and sleep.
    
    // make sure you can see this mood scale in the diary. then figure out converting this scale to its string representation, and displya in the diary.
    // figure out how to send this scale (in int format) to frontend. make sure it prints in debugging on frontend. and then sunny can work on it. figure out where on frontend it should appear.

    
    
    
    
//    func retrieveEmotionScale(_ latestFourUserMessagesContent: [String]) async {
//        let latestFourConversations = latestFourUserMessagesContent.joined(separator: "\n")
//        print("\n\nIN EMOTION SCALE RETRIEVAL FILE:\n", latestFourUserMessagesContent, "\n\n")
//
//        self.moodPrompt.append(ChatMessage(role: .user, content: latestFourConversations))
//
//        do {
//            self.responseText = ""
//
//            let stream = try openAI.generateChatCompletionStreaming(
//                parameters: ChatParameters(model: .chatGPTTurbo, messages: moodPrompt)
//            )
//
//            for try await result in stream {
//                if let delta = result.choices[0].delta {
//                    DispatchQueue.main.async { [weak self] in
//                        guard let self = self else { return }
//                        if let role = delta.role {
//                            //                        self.responseText += "\(role.rawValue.capitalized): "
//                            //                        print("delat: \(delta.role?.rawValue)")
//                        } else if let content = delta.content {
//                            print("\n\nRECEIVED CONTENT:", content, "\n\n")
//                            self.mood += Int(content ?? "5") ?? 5
////                            let content = Int(content)
////                            self.mood += content
//                        }
//                    }
//                }
//            }
////            DispatchQueue.main.async { [weak self] in
////                guard let self = self else { return }
////                self.mood.append(ChatMessage(role: .assistant, content: self.responseText.mood))
////                print("Final response: \(self.responseText)")
////            }
//        } catch {
//            print("Error processing text: \(error)")
//        }
//    }
    
    
   
    
    
//    func retrieveEmotionScale(_ latestFourUserMessagesContent: [String]) {
//        let latestFourConversations = latestFourUserMessagesContent.joined(separator: "\n")
//        print("\n\nIN EMOTION SCALE RETRIEVAL FILE:\n", latestFourUserMessagesContent, "\n\n")
//
//        self.moodPrompt.append(ChatMessage(role: .user, content: latestFourConversations))
//
//        do {
//            self.responseText = ""
//
//            // Perform the asynchronous operation synchronously
//            let result = try await openAI.generateChatCompletion(
//                parameters: ChatParameters(model: .chatGPTTurbo, messages: moodPrompt)
//            )
//
//            // Process the result synchronously
//            for choice in result.choices {
//                if let delta = choice.delta {
//                    if let content = delta.content {
//                        print("\n\nRECEIVED CONTENT:", content, "\n\n")
//                        self.mood += Int(content ?? "5") ?? 5
//                    }
//                }
//            }
//        } catch {
//            print("Error processing text: \(error)")
//        }
//    }
    
    
    
    
    
//    func retrieveEmotionScale(_ latestFourUserMessagesContent: [String]) {
//        let latestFourConversations = latestFourUserMessagesContent.joined(separator: "\n")
//        print("\n\nIN EMOTION SCALE RETRIEVAL FILE:\n", latestFourUserMessagesContent, "\n\n")
//
//        self.moodPrompt.append(ChatMessage(role: .user, content: latestFourConversations))
//        print("\n\n(IN EMOTION SCALE RETRIEVAL FILE) self.moodPrompt:\n", self.moodPrompt, "\n\n")
//
//        do {
//            // Perform the asynchronous operation
//            Task {
//                do {
//                    let result = try await openAI.generateChatCompletion(parameters: ChatParameters(model: .chatGPTTurbo, messages: self.moodPrompt))
//                    print("\n\n(IN EMOTION SCALE RETRIEVAL FILE) result:\n", result, "\n\n")
//
////                    // Process the result synchronously
////                    for choice in result.choices {
////                        print("\n\n(IN EMOTION SCALE RETRIEVAL FILE) choice:", choice, "\n\n")
////                        if let delta = choice.delta {
////                            print("\n\n(IN EMOTION SCALE RETRIEVAL FILE) delta:", delta, "\n\n")
////                            if let content = delta.content {
////                                print("\n\nRECEIVED CONTENT:", content, "\n\n")
////                                self.mood += Int(content ?? "5") ?? 5
////                            }
////                        }
////                    }
//
//
//
////                    // Process the result synchronously
////                    for choice in result.choices {
////                        print("\n\n(IN EMOTION SCALE RETRIEVAL FILE) choice:", choice, "\n\n")
////                        if let delta = choice.delta {
////                            print("\n\nType of delta:", type(of: delta), "\n\n")
////                            print("\n\n(IN EMOTION SCALE RETRIEVAL FILE) delta:", delta, "\n\n")
////                            if let content = delta.content {
////                                print("\n\nRECEIVED CONTENT:", content, "\n\n")
////                                self.mood += Int(content ?? "5") ?? 5
////                            }
////                        }
////                    }
//
//
//
//                    // Process the result synchronously
//                    for choice in result.choices {
//                        print("\n\n(IN EMOTION SCALE RETRIEVAL FILE) choice:", choice, "\n\n")
//                        if let delta = choice.delta {
//                            print("\n\nType of delta:", type(of: delta), "\n\n")
//                            print("\n\n(IN EMOTION SCALE RETRIEVAL FILE) delta:", delta, "\n\n")
//                            if let content = delta.content {
//                                print("\n\nRECEIVED CONTENT:", content, "\n\n")
//                                self.mood += Int(content ?? "5") ?? 5
//                            }
//                        }
//                    }
//                } catch {
//                    print("Error processing text: \(error)")
//                }
//            }
//        } catch {
//            print("Error processing text: \(error)")
//        }
//    }
    
    
    
    
    
    func retrieveEmotionScale(_ latestFourUserMessagesContent: [String]) {
        let latestFourConversations = latestFourUserMessagesContent.joined(separator: "\n")
        print("\n\nIN EMOTION SCALE RETRIEVAL FILE:\n", latestFourUserMessagesContent, "\n\n")
        
        self.moodPrompt.append(ChatMessage(role: .user, content: latestFourConversations))
        print("\n\n(IN EMOTION SCALE RETRIEVAL FILE) self.moodPrompt:\n", self.moodPrompt, "\n\n")
        
        do {
            // Perform the asynchronous operation
            Task {
                var responseReceived = false
                while !responseReceived {
                    do {
                        let result = try await openAI.generateChatCompletion(parameters: ChatParameters(model: .chatGPTTurbo, messages: self.moodPrompt))
                        print("\n\n(IN EMOTION SCALE RETRIEVAL FILE) result:\n", result, "\n\n")
                        
                        // Process the result synchronously
                        for choice in result.choices {
                            print("\n\n(IN EMOTION SCALE RETRIEVAL FILE) choice:", choice, "\n\n")
                            if let delta = choice.delta {
                                print("\n\nType of delta:", type(of: delta), "\n\n")
                                print("\n\n(IN EMOTION SCALE RETRIEVAL FILE) delta:", delta, "\n\n")
                                if let content = delta.content {
                                    print("\n\nRECEIVED CONTENT:", content, "\n\n")
                                    self.mood += Int(content ?? "5") ?? 5
                                    responseReceived = true
                                }
                            }
                        }
                    } catch {
                        print("Error processing text: \(error)")
                    }
                    
                    // Add a delay before checking for response again
                    await Task.sleep(500) // Sleep for 500 milliseconds (adjust as needed)
                }
            }
        } catch {
            print("Error processing text: \(error)")
        }
    }

}
