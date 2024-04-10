//
//  SpeechRecognizer.swift
//  Garden_Of_Memory
//
//  Created by Grace on 10/4/2024.
//

import Foundation
import AVFoundation
import Speech
import SwiftUI

/// A helper for transcribing speech to text using SFSpeechRecognizer and AVAudioEngine.
actor SpeechRecognizer: ObservableObject {
    enum RecognizerError: Error {
        case nilRecognizer
        case notAuthorizedToRecognize
        case notPermittedToRecord
        case recognizerIsUnavailable
        
        var message: String {
            switch self {
            case .nilRecognizer: return "Can't initialize speech recognizer"
            case .notAuthorizedToRecognize: return "Not authorized to recognize speech"
            case .notPermittedToRecord: return "Not permitted to record audio"
            case .recognizerIsUnavailable: return "Recognizer is unavailable"
            }
        }
    }
    
    @MainActor var transcript: String = ""
    
    private var audioEngine: AVAudioEngine?
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private let recognizer: SFSpeechRecognizer?
    
    // Used to detect when the user stops speaking, to trigger ChatGPT's API
    private var silenceTimer: Timer?
    
    private let conversationManager = ConversationManager()
        
    /**
     Initializes a new speech recognizer. If this is the first time you've used the class, it
     requests access to the speech recognizer and the microphone.
     */
    init() {
        print("Initializing SpeechRecognizer")
        recognizer = SFSpeechRecognizer()
        guard recognizer != nil else {
            transcribe(RecognizerError.nilRecognizer)
            return
        }
        
        Task {
            do {
                print("Checking authorization")
                guard await SFSpeechRecognizer.hasAuthorizationToRecognize() else {
                    throw RecognizerError.notAuthorizedToRecognize
                }
                guard await AVAudioSession.sharedInstance().hasPermissionToRecord() else {
                    throw RecognizerError.notPermittedToRecord
                }
                print("Authorization granted")
            } catch {
                transcribe(error)
            }
        }
    }
    
    @MainActor func startTranscribing() {
        print("\nFUNCTION RUNNING: startTranscribing()\n")
        Task {
            await transcribe()
        }
    }
    
    @MainActor func resetTranscript() {
        print("\nFUNCTION RUNNING: resetTranscript()\n")
        Task {
            await reset()
        }
    }
    
    @MainActor func stopTranscribing() {
        print("\nFUNCTION RUNNING: stopTranscribing()\n")
        Task {
            await reset()
        }
    }
    
    /**
     Begin transcribing audio.
     
     Creates a `SFSpeechRecognitionTask` that transcribes speech to text until you call `stopTranscribing()`.
     The resulting transcription is continuously written to the published `transcript` property.
     */
    private func transcribe() {
        print("\nFUNCTION RUNNING: transcribe()\n")
        guard let recognizer, recognizer.isAvailable else {
            self.transcribe(RecognizerError.recognizerIsUnavailable)
            return
        }
        
        do {
            let (audioEngine, request) = try Self.prepareEngine()
            self.audioEngine = audioEngine
            self.request = request
            
            print("Starting recognition task")
            self.task = recognizer.recognitionTask(with: request) { [weak self] result, error in
                print("Inside recognition task resultHandler")
                Task {
                    await self?.recognitionHandler(audioEngine: audioEngine, result: result, error: error)
                }
            }
        } catch {
            self.reset()
            self.transcribe(error)
        }
    }
    
    /// Reset the speech recognizer.
    private func reset() {
        print("\nFUNCTION RUNNING: reset()\n")
        task?.cancel()
        audioEngine?.stop()
        audioEngine = nil
        request = nil
        task = nil
    }
    
    private static func prepareEngine() throws -> (AVAudioEngine, SFSpeechAudioBufferRecognitionRequest) {
        print("\nFUNCTION RUNNING: prepareEngine()\n")
        let audioEngine = AVAudioEngine()
        
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playAndRecord, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        let inputNode = audioEngine.inputNode
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            request.append(buffer)
        }
        audioEngine.prepare()
        try audioEngine.start()
        
        return (audioEngine, request)
    }

    nonisolated private func recognitionHandler(audioEngine: AVAudioEngine, result: SFSpeechRecognitionResult?, error: Error?) async {
        print("\nFUNCTION RUNNING: recognitionHandler()\n")
        print("Handling recognition result")
        
        // Check if result is nil
        guard let result = result else {
            print("Recognition result is nil")
            return
        }
        
        let receivedError = error != nil
        
        // Check if there's a final result or an error
        if receivedError {
            // Handle error
            print("Received error:", error!)
        } else {
            // Debugging statements for transcribing
            print("Calling transcribe function")
            transcribe(result.bestTranscription.formattedString)
            print("Transcription completed")
            
            if !conversationManager.isConversationInProgress() {
                conversationManager.startConversation()
                // Call determineFinalResult after the conversation ends
                DispatchQueue.global().asyncAfter(deadline: .now() + 3) { // waits 3 seconds before calling determineFinalResult()
                    self.conversationManager.endConversation()
                    self.determineFinalResult(result: result) { isFinal in
                        print("Completion handler called with isFinal:", isFinal)
                        if isFinal {
                            print("isFinal = true, calling ChatGPT's API")
                            
                            // Extract the text from the SFSpeechRecognitionResult
                            let transcriptionText = result.bestTranscription.formattedString
                            
                        } else {
                            print("isFinal = false, will not be calling ChatGPT's API")
                        }
                    }
                }
            } else {
                print("Conversation already in progress")
            }
        }
        
        // Add a final print statement to ensure the function is fully executed
        print("Recognition handler complete")
    }

    nonisolated private func determineFinalResult(result: SFSpeechRecognitionResult, completion: @escaping (Bool) -> Void) {
        print("\nFUNCTION RUNNING: determineFinalResult()\n")
        
        // Check if there are any segments in the transcription result
        guard let lastSegment = result.bestTranscription.segments.last else {
            print("No segments found")
            completion(false) // Call completion handler with false if no segments found
            return
        }
        
        // Simulate processing time
        DispatchQueue.global().asyncAfter(deadline: .now() + 3) { // waits another 3 seconds to make isFinal = true, in turn calling ChatGPT's API
            completion(true) // Assume end of conversation after 3 seconds
        }
    }

    nonisolated private func transcribe(_ message: String) {
        print("\nFUNCTION RUNNING: 2nd transcribe() message\n")
        print("Transcribing message: \(message)")
        Task { @MainActor in
            transcript = message
        }
    }
    nonisolated private func transcribe(_ error: Error) {
        print("\nFUNCTION RUNNING: 2nd transcribe() error\n")
        print("Transcribing error: \(error.localizedDescription)")
        var errorMessage = ""
        if let error = error as? RecognizerError {
            errorMessage += error.message
        } else {
            errorMessage += error.localizedDescription
        }
        Task { @MainActor [errorMessage] in
            transcript = "<< \(errorMessage) >>"
        }
    }
}


extension SFSpeechRecognizer {
    static func hasAuthorizationToRecognize() async -> Bool {
        print("Checking authorization to recognize")
        return await withCheckedContinuation { continuation in
            requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
}


extension AVAudioSession {
    func hasPermissionToRecord() async -> Bool {
        print("Checking permission to record")
        return await withCheckedContinuation { continuation in
            requestRecordPermission { authorized in
                continuation.resume(returning: authorized)
            }
        }
    }
}
