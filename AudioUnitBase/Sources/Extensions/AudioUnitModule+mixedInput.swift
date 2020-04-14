//
//  AudioUnitModule+mixedInput.swift
//  AudioUnitBase
//
//  Created by Yauheni Lychkouski on 4/13/20.
//  Copyright © 2020 Yauheni Lychkouski. All rights reserved.
//

import AVFoundation

public extension AudioUnitModule {
    func mixedInput(at index: AUAudioFrameCount) -> Float32 {
        var result = Float32(0)
        for idx in 0..<audioInputs.count {
            let input = audioInputs[idx]
            if idx == 0 {
                result = input[index]
            } else {
                result += input[index]
            }
        }
        return result
    }
}
