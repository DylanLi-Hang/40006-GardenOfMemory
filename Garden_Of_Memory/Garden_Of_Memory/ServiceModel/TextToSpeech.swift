//
//  TextToSpeech.swift
//  Garden_Of_Memory
//
//  Created by Grace on 9/5/2024.
//

import Foundation
import AVFoundation

class TextToSpeechViewModel: NSObject, ObservableObject {
        
    // Create a speech synthesizer.
    let synthesizer = AVSpeechSynthesizer()
    let viewModel = ViewModel.shared
    
    override init() {
        super.init()
        synthesizer.delegate = self
    }
        
//    // Method to trigger speech synthesis with specified text.
//    func speak(_ text: String) {
//        let utterance = AVSpeechUtterance(string: text)
//        
//        // Retrieve the British English voice.
//        let voice = AVSpeechSynthesisVoice(language: "en-GB")
//        
//        // Assign the voice to the utterance.
//        utterance.voice = voice
//        
//        // Set other properties as needed, like rate, pitch, and volume.
//        utterance.rate = AVSpeechUtteranceDefaultSpeechRate // Normal speech rate
//        utterance.pitchMultiplier = 1.1
//        utterance.postUtteranceDelay = 0.2
//        utterance.volume = 0.7
//        
//        // Tell the synthesizer to speak the utterance.
//        synthesizer.speak(utterance)
//    }
    
    func speak(_ string: String) {
        let utterance = AVSpeechUtterance(string: string)
        synthesizer.speak(utterance)
    }
    
}

extension TextToSpeechViewModel: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("all done")
        viewModel.status = .idle
    }
}
