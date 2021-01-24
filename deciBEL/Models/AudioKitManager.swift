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
    
    var pitch: AUValue = 0.0
    var amplitude: AUValue?
    
    private init() {
        let microphone = AKMicrophone()
        tracker = AKAmplitudeTracker(microphone)
        let silence = AKBooster(tracker, gain: 0)
        AudioKit.output = silence
    }
    
    func startAudioKit() {
        do {
            try AudioKit.start()
        } catch {
            // TODO: Implement
        }
    }
    
    func stopAudioKit() {
        do {
            try AudioKit.stop()
        } catch {
            // TODO: Implement
        }
    }
}
