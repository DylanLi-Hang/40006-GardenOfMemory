//
//  ViewModel.swift
//  MyFirstImmersive
//
//  Created by Dylan on 20/4/2024.
//
//  This code defines two enums, `AvatarStatus` and `AIModel`, to manage the states of an avatar and the types of AI models used, respectively. It also defines an observable `ViewModel` class to manage application state related to avatar status, speech recognition, and AI model configuration. ViewModel is used in multiple files, sicne it's observed, it can update many views.

import Foundation

enum AvatarStatus: String, Identifiable, CaseIterable, Equatable {
    var id: Self { self }
    
    case idle
    case listening
    case responding
    case notListening
    
    var currentStatus: String {
        switch self {
        case .idle: return "idle"
        case .listening: return "listening"
        case .responding: return "responding"
        case .notListening: return "notRecording"
        }
    }
    func next() -> AvatarStatus {
        let allCases = Self.allCases
        if let currentIndex = allCases.firstIndex(of: self), currentIndex < allCases.count - 1 {
            return allCases[currentIndex + 1]
        } else {
            return allCases.first!
        }
    }
}

enum AIModel: String, Identifiable, CaseIterable, Equatable {
    var id: Self { self }
    
    case openAI
    case gemini
}


@Observable
class ViewModel {
    static let shared = ViewModel()
    
    // MARK: - Avatar
    var terrarium = false {
        didSet {
            if terrarium == false {
                print("Stop playing audio")
                AudioManager.shared.stopAudio()
            }
        }
    }
    
    var status: AvatarStatus = .notListening
    var recognizationStatus = false
    var isCancelled = true
    var mood = 4


    // MARK: - SpeechRecognition & AI
    var aimodel: AIModel = .gemini
    var waitingTime: Double = 4
}
