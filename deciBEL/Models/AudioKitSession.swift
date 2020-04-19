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
    
    static let microphone = AKMicrophone()
    
    let tracker = AKAmplitudeTracker(microphone)
    let silence = AKBooster(tracker, gain: 0)
    let fft = AKFFTTap(microphone!)
    AudioKit.output = silence

    
}
