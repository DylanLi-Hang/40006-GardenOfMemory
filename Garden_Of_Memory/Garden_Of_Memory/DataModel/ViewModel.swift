//
//  ViewModel.swift
//  MyFirstImmersive
//
//  Created by Dylan on 20/4/2024.
//

import Foundation

enum Animation: String, Codable {
    case idle, listening, waitForResponse, responding;
 
    var startTime: TimeInterval {
        // since animations are 30FPS..
        Double(startFrame) / 30
    }
 
    var duration: TimeInterval {
        // same here
        Double(endFrame - startFrame) / 30.0
    }
 
    var startFrame: Int {
        switch self {
            case .idle:
                return 0
 
            case .listening:
                return 90
 
            case .waitForResponse:
                return 180
            
            case .responding:
                return 220
        }
    }
 
    var endFrame: Int {
        switch self {
            case .idle:
                return 20
 
            case .listening:
                return 180
 
            case .waitForResponse:
                return 220
            
            case .responding:
                return 240
        }
    }
}

enum AvatarStatus: String, Identifiable, CaseIterable, Equatable {
    var id: Self { self }
    
    case idle
    case listening
    case waitForResponse
    case responding
    case notListening
    
    var currentStatus: String {
        switch self {
        case .idle: return "idle"
        case .listening: return "listening"
        case .responding: return "responding"
        case .waitForResponse: return "waiting"
        case .notListening: return "notRecording"
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
    var status: AvatarStatus = .notListening
    var animation: Animation = .idle


    // MARK: - SpeechRecognition & AI
    var aimodel: AIModel = .openAI
    var waitingTime: Double = 4
}
