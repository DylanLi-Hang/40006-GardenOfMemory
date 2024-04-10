//
//  ConversationManager.swift
//  Garden_Of_Memory
//
//  Created by Grace on 10/4/2024.
//

import Foundation

class ConversationManager {
    private var conversationInProgress = false
    
    func startConversation() {
        guard !conversationInProgress else {
            print("Conversation is already in progress")
            return
        }
        conversationInProgress = true
        print("Conversation started")
    }
    
    func endConversation() {
        guard conversationInProgress else {
            print("No conversation in progress to end")
            return
        }
        conversationInProgress = false
        print("Conversation ended")
    }
    
    func isConversationInProgress() -> Bool {
        return conversationInProgress
    }
}
