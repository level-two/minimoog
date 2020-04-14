//
//  AudioBuffer.swift
//  AudioUnitBase
//
//  Created by Yauheni Lychkouski on 4/10/20.
//  Copyright © 2020 Yauheni Lychkouski. All rights reserved.
//

import AVFoundation

public typealias Buffer = UnsafeMutablePointer<Float32>

public extension Buffer {
    subscript(index: AUAudioFrameCount) -> Float32 {
        get {
            return self[Int(index)]
        }

        set(newValue) {
            self[Int(index)] = newValue
        }
    }
}
