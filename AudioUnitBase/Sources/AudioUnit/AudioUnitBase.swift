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
import CoreAudioKit
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
    fileprivate weak var visualPresentation: InstruemtnVisualPresentation?
    fileprivate var inputBus: AUAudioUnitBus?
    fileprivate var outputBus: AUAudioUnitBus
    fileprivate var curPresetIndex = 0 // Positive - factory, negative - user
    fileprivate var curPresetName = ""
    fileprivate var audioBufferList: UnsafeMutableAudioBufferListPointer?
    fileprivate var pcmBuffer: AVAudioPCMBuffer?

    init(instrument: Instrument,
         visualPresentation: InstruemtnVisualPresentation,
         componentDescription: AudioComponentDescription,
         options: AudioComponentInstantiationOptions = []) throws {

        guard let defaultFormat = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1) else {
            throw AudioUnitError.invalidDefaultAudioFormat
        }

        // self.inputBus = try AUAudioUnitBus(format: defaultFormat)
        self.outputBus = try AUAudioUnitBus(format: defaultFormat)
        self.instrument = instrument
        self.visualPresentation = visualPresentation

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
    override public func supportedViewConfigurations(_ availableViewConfigurations: [AUAudioUnitViewConfiguration]) -> IndexSet {
        guard let supportedConfigurations = visualPresentation?.supportedViewConfigurations else { return [] }

        func maxRelativeDifference(w1: CGFloat, h1: CGFloat, w2: CGFloat, h2: CGFloat) -> CGFloat {
            let wDiff = (max(w1, w2) - min(w1, w2)) / max(w1, w2)
            let hDiff = (max(h1, h2) - min(h1, h2)) / max(h1, h2)
            return max(wDiff, hDiff)
        }

        var indices = IndexSet()
        for i in 0..<availableViewConfigurations.count {
            let w = availableViewConfigurations[i].width
            let h = availableViewConfigurations[i].height

            if let _ = supportedConfigurations.first(where: { maxRelativeDifference(w1: w, h1: h, w2: $0.width, h2: $0.height) < 0.2 }) {
                indices.insert(i)
            }
        }
        return indices
    }

    override public func select(_ viewConfiguration: AUAudioUnitViewConfiguration) {
        visualPresentation?.select(viewConfiguration)
    }
}

extension AudioUnitBase {
    override public func allocateRenderResources() throws {
        try super.allocateRenderResources()

        pcmBuffer = AVAudioPCMBuffer(pcmFormat: outputBus.format, frameCapacity: maximumFramesToRender)
        pcmBuffer?.frameLength = maximumFramesToRender
        audioBufferList = UnsafeMutableAudioBufferListPointer(self.pcmBuffer?.mutableAudioBufferList)

        instrument.midiEventQueueManager.allocateResources(framesCount: maximumFramesToRender)
        instrument.outputModule.allocateRenderResources(Float32(outputBus.format.sampleRate), maximumFramesToRender)
    }

    override public func deallocateRenderResources() {
        super.deallocateRenderResources()
        instrument.midiEventQueueManager.deallocateResources()
        instrument.outputModule.deallocateRenderResources()
        pcmBuffer = nil
        audioBufferList = nil
    }

    override public var internalRenderBlock: AUInternalRenderBlock {
        return { [unowned self] _, timestamp, frameCount, _, outputData, realtimeEventListHead, _ in
            guard let audioBufferList = self.audioBufferList else { return kAudioUnitErr_Uninitialized }

            self.instrument.midiEventQueueManager.newCycle()

            let renderTime = AUEventSampleTime(timestamp.pointee.mSampleTime)
            var event = realtimeEventListHead?.pointee

            while let curEvent = event {
                let eventTime = curEvent.head.eventSampleTime
                let eventFrame = AUAudioFrameCount(eventTime - renderTime)
                guard eventFrame < frameCount  else { break }

                if curEvent.head.eventType == .parameter {
//                    self.instrument.setParameter(address: curEvent.parameter.parameterAddress, value: curEvent.parameter.value)
                } else if curEvent.head.eventType == .MIDI, let midiEvent = MidiEvent(from: curEvent.MIDI) {
                    self.instrument.midiEventQueueManager.push(midiEvent, at: eventFrame)
                }

                event = curEvent.head.next?.pointee
            }

            let outBufferList = UnsafeMutableAudioBufferListPointer(outputData)
            for idx in outBufferList.indices where outBufferList[idx].mData == nil {
                outBufferList[idx].mNumberChannels = audioBufferList[idx].mNumberChannels
                outBufferList[idx].mDataByteSize = audioBufferList[idx].mDataByteSize
                outBufferList[idx].mData = audioBufferList[idx].mData
            }
            var buffers = outBufferList.compactMap { $0.mData?.assumingMemoryBound(to: Float32.self) }
            self.instrument.outputModule.render(frameCount, into: &buffers)

            return noErr
        }
    }
}
