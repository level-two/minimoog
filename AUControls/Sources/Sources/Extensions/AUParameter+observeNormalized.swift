//
//  AUParameter+observeNormalizedValue.swift
//  AUControls
//
//  Created by Yauheni Lychkouski on 2/6/20.
//  Copyright © 2020 Yauheni Lychkouski. All rights reserved.
//

import AudioToolbox

extension AUParameter {
    func observeNormalizedValue(callback: @escaping (Double) -> Void) -> AUParameterObserverToken {
        return token(byAddingParameterObserver: { [weak self] _, value in
            guard let self = self else { return }

            let normalizedValue = Double(value) // TBD

//            @constant        kAudioUnitParameterUnit_Generic
//            untyped value generally between 0.0 and 1.0
//            @constant        kAudioUnitParameterUnit_Indexed
//            takes an integer value (good for menu selections)
//            @constant        kAudioUnitParameterUnit_Boolean
//            0.0 means FALSE, non-zero means TRUE
//            @constant        kAudioUnitParameterUnit_Percent
//            usually from 0 -> 100, sometimes -50 -> +50
//            @constant        kAudioUnitParameterUnit_Seconds
//            absolute or relative time
//            @constant        kAudioUnitParameterUnit_SampleFrames
//            one sample frame equals (1.0/sampleRate) seconds
//            @constant        kAudioUnitParameterUnit_Phase
//            -180 to 180 degrees
//            @constant        kAudioUnitParameterUnit_Rate
//            rate multiplier, for playback speed, etc. (e.g. 2.0 == twice as fast)
//                @constant        kAudioUnitParameterUnit_Hertz
//                absolute frequency/pitch in cycles/second
//                @constant        kAudioUnitParameterUnit_Cents
//                unit of relative pitch
//                @constant        kAudioUnitParameterUnit_RelativeSemiTones
//                useful for coarse detuning
//            @constant        kAudioUnitParameterUnit_MIDINoteNumber
//            absolute pitch as defined in the MIDI spec (exact freq may depend on tuning table)
//            @constant        kAudioUnitParameterUnit_MIDIController
//            a generic MIDI controller value from 0 -> 127
//            @constant        kAudioUnitParameterUnit_Decibels
//            logarithmic relative gain
//            @constant        kAudioUnitParameterUnit_LinearGain
//            linear relative gain
//            @constant        kAudioUnitParameterUnit_Degrees
//            -180 to 180 degrees, similar to phase but more general (good for 3D coord system)
//            @constant        kAudioUnitParameterUnit_EqualPowerCrossfade
//            0 -> 100, crossfade mix two sources according to sqrt(x) and sqrt(1.0 - x)
//            @constant        kAudioUnitParameterUnit_MixerFaderCurve1
//            0.0 -> 1.0, pow(x, 3.0) -> linear gain to simulate a reasonable mixer channel fader response
//            @constant        kAudioUnitParameterUnit_Pan
//            standard left to right mixer pan
//            @constant        kAudioUnitParameterUnit_Meters
//            distance measured in meters
//            @constant        kAudioUnitParameterUnit_AbsoluteCents
//            absolute frequency measurement :
//                if f is freq in hertz then absoluteCents = 1200 * log2(f / 440) + 6900
//            @constant        kAudioUnitParameterUnit_Octaves
//            octaves in relative pitch where a value of 1 is equal to 1200 cents
//            @constant        kAudioUnitParameterUnit_BPM
//            beats per minute, ie tempo
//            @constant        kAudioUnitParameterUnit_Beats
//            time relative to tempo, i.e., 1.0 at 120 BPM would equal 1/2 a second
//            @constant        kAudioUnitParameterUnit_Milliseconds
//            parameter is expressed in milliseconds
//            @constant        kAudioUnitParameterUnit_Ratio
//            for compression, expansion ratio, etc.
//                @constant        kAudioUnitParameterUnit_CustomUnit
//                this is the parameter unit type for parameters that present a custom unit name
//            */
//            public enum AudioUnitParameterUnit : UInt32 {

            switch self.unit {
            case .generic:
            case .indexed:
            case .boolean:
            case .percent:
            case .seconds:
            case .sampleFrames:
            case .phase:
            case .rate:
            case .hertz:
            case .cents:
            case .relativeSemiTones:
            case .midiNoteNumber:
            case .midiController:
            case .decibels:
            case .linearGain:
            case .degrees:
            case .equalPowerCrossfade:
            case .mixerFaderCurve1:
            case .pan:
            case .meters:
            case .absoluteCents:
            case .octaves:
            case .BPM:
            case .beats:
            case .milliseconds:
            case .ratio:
            case .customUnit:
            default:
                break
            }

            callback(normalizedValue)
        })
    }
}
