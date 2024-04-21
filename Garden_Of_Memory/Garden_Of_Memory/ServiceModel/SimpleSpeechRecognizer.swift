//
//  SpeechRecognizer.swift
//  MyFirstImmersive
//
//  Created by Dylan on 19/4/2024.
//

import Foundation
import Speech
import SwiftSpeechRecognizer

struct SimpleSpeechRecognizer {
    var authorizationStatusChanged: (SFSpeechRecognizerAuthorizationStatus) -> Void
    var speechRecognitionStatusChanged: (SpeechRecognitionStatus) -> Void
    var utteranceChanged: (String) -> Void

    private let speechRecognizer = SwiftSpeechRecognizer.live

    func start() {
        speechRecognizer.requestAuthorization()
        Task {
            for await authorizationStatus in speechRecognizer.authorizationStatus() {
                authorizationStatusChanged(authorizationStatus)

                switch authorizationStatus {
                case .authorized:
                    startRecording()
                default:
                    print("Not authorized to use speech recognizer")
                }
            }
        }
    }

    private func startRecording() {
        do {
            try speechRecognizer.startRecording()
            Task {
                for await recognitionStatus in speechRecognizer.recognitionStatus() {
                    speechRecognitionStatusChanged(recognitionStatus)
                }
            }

            Task {
                for await newUtterance in speechRecognizer.newUtterance() {
                    utteranceChanged(newUtterance)
                }
            }
        } catch {
            print("Something went wrong: \(error)")
            speechRecognizer.stopRecording()
        }
    }
    
    func stop() {
        speechRecognizer.stopRecording()
    }
}
