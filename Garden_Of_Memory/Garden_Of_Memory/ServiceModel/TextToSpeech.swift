//
//  TextToSpeech.swift
//  Garden_Of_Memory
//
//  Created by Grace on 9/5/2024.
//

import Foundation
import AVFoundation

class TextToSpeechViewModel: NSObject, ObservableObject {
    
    // Create an utterance.
    let utterance = AVSpeechUtterance(string: "The quick brown fox jumped over the lazy dog.")

    // Configure the utterance.
    override init() {
        super.init()
        
//        utterance.rate = 0.57
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate // Normal speech rate
        utterance.pitchMultiplier = 1.1
        utterance.postUtteranceDelay = 0.2
        utterance.volume = 0.7

        // Retrieve the British English voice.
        let voice = AVSpeechSynthesisVoice(language: "en-GB")
        
        // Assign the voice to the utterance.
        utterance.voice = voice
    }
    
    // Create a speech synthesizer.
    let synthesizer = AVSpeechSynthesizer()
    
//    // Method to trigger speech synthesis.
//    func speak() {
//        // Tell the synthesizer to speak the utterance.
//        synthesizer.speak(utterance)
//    }
    
    // Method to trigger speech synthesis with specified text.
    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        
        // Tell the synthesizer to speak the utterance.
        synthesizer.speak(utterance)
    }
    
}
