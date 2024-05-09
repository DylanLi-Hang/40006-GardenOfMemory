//
//  SpeechRecognizerViewModel.swift
//  MyFirstImmersive
//
//  Created by Dylan on 20/4/2024.
//


import Foundation
import SwiftData
import Combine
//import Speech
import SwiftSpeechRecognizer
import OpenAIKit
import GoogleGenerativeAI

class SpeechRecognitionViewModel: ObservableObject {
    
    @Published var recognizedText = ""
    @Published var recognizationStatus = false
    @Published var isAuthorized = false
    
    @Published var messages: [ChatMessage] = []
    @Published var responseText: String = ""
    @Published var isCompleting: Bool = false
    @Published var mood: Int = 5
    @Published var tags: [String] = []
    
    var lastProcessedLength: Int = 0
    var speechRecognizer: SimpleSpeechRecognizer? = nil
    var openAI: OpenAI
    var gemini: GenerativeModel
    private var chat: Chat?
    
    
    let viewModel = ViewModel.shared
    
    private var debouncer: AnyCancellable?
    private var lastPrintedText: String?
    
    // For emotion scale retrieval
    private var conversationCount = 0 // Counter to track the number of conversations
    private let emotionViewModel = EmotionScaleViewModel()
    private let conversationTagsViewModel = ConversationTagsViewModel()
    
    init() {
        let config = Configuration(
            organizationId: "",
            apiKey: APIKey.openai
            
        )
        self.openAI = OpenAI(config)
        
        let geminiConfig = GenerationConfig(
            temperature: 0.1,
            maxOutputTokens: 2048
        )
        
        //        let textPart = ModelContent.Part.text(Prompt.systemInitPrompt)
        //        let modelContent = ModelContent(role: "system", parts: [textPart])
        
        self.gemini = GenerativeModel(name: "gemini-1.0-pro", apiKey: APIKey.default, generationConfig: geminiConfig)
        
        self.messages.append(ChatMessage(role: .system, content: Prompt.systemInitPrompt))
        if viewModel.aimodel == .gemini {
            var history: [ModelContent] = []
            history = Prompt.history
            for message in messages {
                if let messageContent = message.content {
                    if message.role == .user {
                        history.append(ModelContent(role: "user", parts: messageContent))
                    } else if message.role == .assistant {
                        history.append(ModelContent(role: "model", parts: messageContent))
                    }
                }
            }
            self.chat = gemini.startChat(history: Prompt.history)
        }
    }
    
    func changeRecognitionStatus() {
        if (speechRecognizer == nil) {
            speechRecognizer = SimpleSpeechRecognizer(
                authorizationStatusChanged: { newAuthorizationStatus in
                    print("Authorization status changed: \(newAuthorizationStatus)")
                },
                speechRecognitionStatusChanged: { newRecognitionStatus in
                    print("Recognition status changed: \(newRecognitionStatus)")
                    DispatchQueue.main.async {
                        if newRecognitionStatus == .stopped {
                            self.recognizationStatus = false
                            self.viewModel.status = .notListening
                        } else if newRecognitionStatus == .recording {
                            self.recognizationStatus = true
                            self.viewModel.status = .idle
                        }
                    }
                },
                utteranceChanged: { newUtterance in
                    //                    print("Recognized utterance changed: \(newUtterance)")
                    self.viewModel.status = .listening
                    DispatchQueue.main.async {
                        self.updateRecognizedText(newUtterance)
                    }
                }
            )
        }
        if (speechRecognizer != nil && self.recognizationStatus == true) {
            speechRecognizer?.stop()
        } else if (speechRecognizer != nil && self.recognizationStatus == false) {
            speechRecognizer?.start()
        }
    }
    
    private func updateRecognizedText(_ newUtterance: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.recognizedText = newUtterance
            self.debouncer?.cancel()
            
            self.debouncer = Timer.publish(every: viewModel.waitingTime, on: .main, in: .common)
                .autoconnect()
                .sink { _ in
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        let currentLength = recognizedText.count
                        if currentLength > lastProcessedLength {
                            let startIndex = recognizedText.index(recognizedText.startIndex, offsetBy: lastProcessedLength)
                            let endIndex = recognizedText.endIndex
                            let newText = String(recognizedText[startIndex..<endIndex])
                            Task {
                                print("Value not updated for 5 seconds with value: \(newText)")
                                await self.sendMessage(newText)
                                self.lastProcessedLength = currentLength
                            }
                        }
                    }
                }
        }
    }
    
    private func sendMessage(_ message: String) async {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.messages.append(ChatMessage(role: .user, content: message))
            
            // Increment the conversation count when chatgpt responds
            self.conversationCount += 1
            if self.conversationCount == 4 { // Check if there have been four conversations
                print("Four conversations have been had. Let's retrieve the emotion state.")
                
                // Perform action to retrieve emotion state
                
                let userMessages = self.messages.filter { $0.role == .user }
                let latestFourUserMessages = Array(userMessages.suffix(4))
                let latestFourUserMessagesContent = latestFourUserMessages.compactMap { $0.content }
                
                emotionViewModel.retrieveEmotionScale(latestFourUserMessagesContent) { mood, error in
                    if let mood = mood {
                        self.mood = mood
                    } else if let error = error {
                        print("Error retrieving mood:", error)
                    } else {
                        print("No mood data available")
                    }
                }

                conversationTagsViewModel.retrieveConversationTags(latestFourUserMessagesContent) { tag, error in
                    if let tag = tag {
                        print("Conversation Tag:", tag)
                        self.tags = tag
                    } else if let error = error {
                        print("Error retrieving tag:", error)
                    } else {
                        print("No tag data available")
                    }
                }

                
                // Reset the conversation count to 0 after processing four conversations
                self.conversationCount = 0
            }
        }
        do {
            self.responseText = ""
            self.viewModel.status = .responding
            
            if viewModel.aimodel == .gemini {
                //                let prompt = "Write a story about a magic backpack."
                //                let response = try await gemini.generateContent(prompt)
                //                gemini.modelResourceName.propertyList()
                //                if let text = response.text {
                //                  print(text)
                //                }
                
                let outputContentStream = chat!.sendMessageStream(message)
                for try await outputContent in outputContentStream {
                    guard let line = outputContent.text else {
                        return
                    }
                    self.responseText = self.responseText + line
                }
            }
            
            if viewModel.aimodel == .openAI {
                let stream = try openAI.generateChatCompletionStreaming(
                    parameters: ChatParameters(model: .chatGPTTurbo, messages: messages)
                )
                
                for try await result in stream {
                    if let delta = result.choices[0].delta {
                        DispatchQueue.main.async { [weak self] in
                            guard let self = self else { return }
                            if let role = delta.role {
                                //                                self.responseText += "\(role.rawValue.capitalized): "
                                //                                print("delat: \(delta.role?.rawValue)")
                            } else if let content = delta.content {
                                self.responseText += content
                            }
                        }
                    }
                }
            }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.messages.append(ChatMessage(role: .assistant, content: self.responseText))
                print("Final response: \(self.responseText)")
                if self.viewModel.status != .notListening {
                    self.viewModel.status = .idle
                }
            }
        } catch {
            print("Error processing text: \(error)")
        }
    }
    
}
