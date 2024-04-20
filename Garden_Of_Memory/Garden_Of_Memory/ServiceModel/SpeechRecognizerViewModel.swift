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
    @Published var isAuthorized = false
    
    @Published var messages: [ChatMessage] = []
    @Published var responseText: String = ""
    @Published var isCompleting: Bool = false
    
    var speechRecognizer: SimpleSpeechRecognizer? = nil
    var openAI: OpenAI
    var gemini: GenerativeModel
    private var chat: Chat?
    
    let viewModel = ViewModel.shared
    
    private var debouncer: AnyCancellable?
    private var lastPrintedText: String?
    
    init() {
        let config = Configuration(
            organizationId: "",
            apiKey: APIKey.openai
        )
        let geminiConfig = GenerationConfig(
          maxOutputTokens: 5000
        )
        self.openAI = OpenAI(config)
        
        let systemInstruction = ModelContent(role: "system", parts: [.text(Prompt.systemInitPrompt)])
        
        self.gemini = GenerativeModel(name: "gemini-1.0-pro", apiKey: APIKey.default, generationConfig: geminiConfig)
        
        self.messages.append(ChatMessage(role: .system, content: Prompt.systemInitPrompt))
        if viewModel.aimodel == .gemini {
            self.chat = gemini.startChat(history: [systemInstruction])
        }
    }
    
    func startRecognition() {
        speechRecognizer = SimpleSpeechRecognizer(
            authorizationStatusChanged: { newAuthorizationStatus in
                print("Authorization status changed: \(newAuthorizationStatus)")
            },
            speechRecognitionStatusChanged: { newRecognitionStatus in
                print("Recognition status changed: \(newRecognitionStatus)")
            },
            utteranceChanged: { newUtterance in
                print("Recognized utterance changed: \(newUtterance)")
                DispatchQueue.main.async {
                    self.updateRecognizedText(newUtterance)
                }
            }
        )
        speechRecognizer?.start()
    }
    
    private func updateRecognizedText(_ newUtterance: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.recognizedText = newUtterance
            self.debouncer?.cancel()
            
            self.debouncer = Timer.publish(every: 5, on: .main, in: .common)
                .autoconnect()
                .sink { _ in
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        if self.recognizedText != self.lastPrintedText {
                            print("Value not updated for 5 seconds: \(self.recognizedText)")
                            Task {
                                await self.sendMessage(self.recognizedText)
                            }
                            self.lastPrintedText = self.recognizedText
                        }
                    }
                }
        }
    }

    private func sendMessage(_ message: String) async {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.messages.append(ChatMessage(role: .user, content: self.recognizedText))
        }
        do {
            self.viewModel.status = .responding
            
            if viewModel.aimodel == .gemini {
                let outputContentStream = gemini.generateContentStream(message)
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
                                self.responseText += "\(role.rawValue.capitalized): "
                            } else if let content = delta.content {
                                self.responseText += content
                                print(self.responseText)
                            }
                        }
                    }
                }
            }
            
            self.messages.append(ChatMessage(role: .assistant, content: self.responseText))
            self.viewModel.status = .idle
            self.responseText = ""
        } catch {
            print("Error processing text: \(error)")
        }
    }
    
    func addChatMessageToEntry(_ chatMessage: ChatMessage) {
        let container = ModelContainer()
        let chatEntry = container.chatEntries.first { $0.date == Date() } ?? ChatEntry(date: Date(), mood: 0, messages: [], tags: [], name: nil)
        
        chatEntry.chatMessages.append(chatMessage)
        
        do {
            try container.save()
        } catch {
            print("Failed to save chat entry: \(error)")
        }
    }
}
