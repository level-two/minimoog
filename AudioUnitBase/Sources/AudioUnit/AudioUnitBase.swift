// -----------------------------------------------------------------------------
//    Copyright (C) 2018 Yauheni Lychkouski.
//
//    This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program.  If not, see <http://www.gnu.org/licenses/>.
// -----------------------------------------------------------------------------

import AudioToolbox
import AVFoundation
import Midi

final class AudioUnitBase: AUAudioUnit {
    public enum AudioUnitError: Error {
        case invalidDefaultAudioFormat
    }

    override public var channelCapabilities: [NSNumber]? {
        return self.instrument.channelCapabilities.map(NSNumber.init)
    }

    override public var inputBusses: AUAudioUnitBusArray {
        return self.curInputBusses
    }

    override public var outputBusses: AUAudioUnitBusArray {
        return self.curOutputBusses
    }

    override public var parameterTree: AUParameterTree? {
        get { return self.instrument.parameterTree }
        set { /* do nothing */ }
    }

    fileprivate lazy var curInputBusses: AUAudioUnitBusArray = {
        let buses = [inputBus].compactMap { $0 }
        return AUAudioUnitBusArray(audioUnit: self, busType: .input, busses: buses)
    }()

    fileprivate lazy var curOutputBusses: AUAudioUnitBusArray = {
        return AUAudioUnitBusArray(audioUnit: self, busType: .output, busses: [outputBus])
    }()

    fileprivate var instrument: Instrument
    fileprivate var inputBus: AUAudioUnitBus?
    fileprivate var outputBus: AUAudioUnitBus
    fileprivate var curPresetIndex = 0 // Positive - factory, negative - user
    fileprivate var curPresetName = ""
    fileprivate var audioBufferList: UnsafeMutableAudioBufferListPointer?
    fileprivate var pcmBuffer: AVAudioPCMBuffer?

    init(with instrument: Instrument, componentDescription: AudioComponentDescription,
         options: AudioComponentInstantiationOptions = []) throws {

        guard let defaultFormat = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1) else {
            throw AudioUnitError.invalidDefaultAudioFormat
        }

        // self.inputBus = try AUAudioUnitBus(format: defaultFormat)
        self.outputBus = try AUAudioUnitBus(format: defaultFormat)
        self.instrument = instrument

        try super.init(componentDescription: componentDescription, options: options)

        currentPreset = factoryPresets?[safe: 0]
    }
}

extension AudioUnitBase {
    override public var factoryPresets: [AUAudioUnitPreset]? {
        let names = instrument.factoryPresets.compactMap { $0["name"] as? String }
        return names.enumerated().map { AUAudioUnitPreset(number: $0.0, name: $0.1) }
    }

    override public var fullState: [String: Any]? {
        get {
            return instrument.presetForCurrentState
        }
        set {
            guard let newValue = newValue else { return }
            instrument.load(preset: newValue)
        }
    }

    override public var currentPreset: AUAudioUnitPreset? {
        get {
            return AUAudioUnitPreset(number: curPresetIndex, name: curPresetName)
        }
        set {
            guard let preset = newValue else { return }
            curPresetIndex = preset.number
            curPresetName = preset.name
            if preset.number >= 0, let factoryPreset = instrument.factoryPresets[safe: preset.number] {
                instrument.load(preset: factoryPreset)
            }
        }
    }
}

extension AudioUnitBase {
    override public func allocateRenderResources() throws {
        try super.allocateRenderResources()

        self.pcmBuffer = AVAudioPCMBuffer(pcmFormat: outputBus.format, frameCapacity: maximumFramesToRender)
        self.pcmBuffer?.frameLength = maximumFramesToRender
        self.audioBufferList = UnsafeMutableAudioBufferListPointer(self.pcmBuffer?.mutableAudioBufferList)

        self.instrument.setAudioFormat(outputBus.format)
    }

    override public func deallocateRenderResources() {
        super.deallocateRenderResources()
        pcmBuffer = nil
        audioBufferList = nil
    }

    override public var internalRenderBlock: AUInternalRenderBlock {
        return { [unowned self] _, timestamp, frameCount, _, outputData, realtimeEventListHead, _ in
            guard let audioBufferList = self.audioBufferList else { return kAudioUnitErr_Uninitialized }

            let outBufferList = UnsafeMutableAudioBufferListPointer(outputData)

            for idx in outBufferList.indices where outBufferList[idx].mData == nil {
                outBufferList[idx].mNumberChannels = audioBufferList[idx].mNumberChannels
                outBufferList[idx].mDataByteSize = audioBufferList[idx].mDataByteSize
                outBufferList[idx].mData = audioBufferList[idx].mData
            }

            let buffers = outBufferList.compactMap { $0.mData?.assumingMemoryBound(to: Float32.self) }

            func render(frames: AUAudioFrameCount, offset: AUAudioFrameCount) {
                let buffersWithOffset = buffers.map { $0 + Int(offset) }
                self.instrument.render(to: buffersWithOffset, frames: frames)
            }

            var lastEventTime = AUEventSampleTime(timestamp.pointee.mSampleTime)
            var framesRemaining = frameCount
            var event = realtimeEventListHead?.pointee

            while let curEvent = event {
                let curEventTime = curEvent.head.eventSampleTime
                let framesInSegment = AUAudioFrameCount(curEventTime - lastEventTime)

                guard framesInSegment <= framesRemaining else { break }

                render(frames: framesInSegment, offset: frameCount - framesRemaining)

                if curEvent.head.eventType == .parameter {
                    self.instrument.setParameter(address: curEvent.parameter.parameterAddress, value: curEvent.parameter.value)
                } else if curEvent.head.eventType == .MIDI, let midiEvent = MidiEvent(from: curEvent.MIDI) {
                    self.instrument.handle(midiEvent: midiEvent)
                }

                lastEventTime = curEventTime
                framesRemaining -= framesInSegment
                event = curEvent.head.next?.pointee
            }

            render(frames: framesRemaining, offset: frameCount - framesRemaining)
            return noErr
        }
    }
}
