//
//  ViewModel.swift
//  MyFirstImmersive
//
//  Created by Dylan on 20/4/2024.
//

import Foundation

enum AvatarStatus: String, Identifiable, CaseIterable, Equatable {
    var id: Self { self }
    
    case idle
    case listening
    case waitForResponse
    case responding
    
    var currentStatus: String {
        switch self {
        case .idle: return "idle"
        case .listening: return "listening"
        case .responding: return "responding"
        case .waitForResponse: return "waiting"
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
    var status: AvatarStatus = .idle


    // MARK: - SpeechRecognition & AI
    var aimodel: AIModel = .gemini
}
