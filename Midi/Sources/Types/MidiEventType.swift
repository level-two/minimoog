//
//  MidiEventType.swift
//  Midi
//
//  Created by Yauheni Lychkouski on 4/13/20.
//  Copyright © 2020 Yauheni Lychkouski. All rights reserved.
//

import Foundation

public enum MidiEventType: Equatable {
    case noteOn
    case noteOff
    case controlChange
    case pitchBend
    case allNotesOff
}
