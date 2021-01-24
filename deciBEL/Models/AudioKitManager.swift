//
//  AudioKitManager.swift
//  deciBEL
//
//  Created by Stefan Olarescu on 19/04/2020.
//  Copyright © 2020 Stefan Olarescu. All rights reserved.
//

import Foundation
import AudioKit

class AudioKitManager {
    
    static let shared = AudioKitManager()
    
    var tracker: AKAmplitudeTracker?
    
    private init() {
        let microphone = AKMicrophone()
        tracker = AKAmplitudeTracker(microphone)
        let silence = AKBooster(tracker, gain: 0)
        AKManager.output = silence
    }
    
    func startAudioKit() {
        do {
            try AKManager.start()
        } catch {
            // TODO: Implement
        }
    }
    
    func stopAudioKit() {
        do {
            try AKManager.stop()
        } catch {
            // TODO: Implement
        }
    }
}
