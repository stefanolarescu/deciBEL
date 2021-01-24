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
    
    let engine = AudioEngine()
    var mic: AudioEngine.InputNode
    var tappableNode1: Mixer
    var tappableNode2: Mixer
    var tappableNode3: Mixer
    var tracker: PitchTap!
    var silence: Fader
    
    var pitch: AUValue = 0.0
    var amplitude: AUValue?
    
    private init() {
        guard let input = engine.input else {
            fatalError()
        }

        mic = input
        tappableNode1 = Mixer(mic)
        tappableNode2 = Mixer(tappableNode1)
        tappableNode3 = Mixer(tappableNode2)
        silence = Fader(tappableNode3, gain: 0)
        engine.output = silence

        tracker = PitchTap(mic) { pitch, amp in
            DispatchQueue.main.async {
                self.pitch = pitch[0]
                self.amplitude = amp[0]
            }
        }
    }
    
    func startAudioKit() {
        do {
            try engine.start()
            tracker.start()
        } catch {
            // TODO: Implement
        }
    }
    
    func stopAudioKit() {
        engine.stop()
    }
}
