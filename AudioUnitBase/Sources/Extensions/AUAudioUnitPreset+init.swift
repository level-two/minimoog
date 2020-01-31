//
//  AUAudioUnitPreset+init.swift
//  AudioUnitBase
//
//  Created by Yauheni Lychkouski on 1/31/20.
//  Copyright © 2020 Yauheni Lychkouski. All rights reserved.
//

import AVFoundation

extension AUAudioUnitPreset {
    convenience init(number: Int, name: String) {
        self.init()
        self.number = number
        self.name = name
    }
}
