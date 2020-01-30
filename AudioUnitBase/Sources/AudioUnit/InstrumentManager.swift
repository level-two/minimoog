// -----------------------------------------------------------------------------
//    Copyright (C) 2020 Yauheni Lychkouski.
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

import Foundation
import AVFoundation
import Midi

final class InstrumentManager {
    private let instrument: Instrument
    private var musicalContextBlock: AUHostMusicalContextBlock?
    private var transportStateBlock: AUHostTransportStateBlock?
    private var outputEventBlock: AUMIDIOutputEventBlock?
    private var audioBufferList: UnsafeMutableAudioBufferListPointer?
    private var pcmBuffer: AVAudioPCMBuffer?

    init(instrument: Instrument) {
        self.instrument = instrument
    }

    func allocateRenderResources(format: AVAudioFormat,
                                 maxFrames: AVAudioFrameCount,
                                 musicalContextBlock: AUHostMusicalContextBlock?,
                                 outputEventBlock: AUMIDIOutputEventBlock?,
                                 transportStateBlock: AUHostTransportStateBlock?) throws {

        self.pcmBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: maxFrames)
        self.pcmBuffer?.frameLength = maxFrames
        self.audioBufferList = UnsafeMutableAudioBufferListPointer(self.pcmBuffer?.mutableAudioBufferList)

        self.instrument.setAudioFormat(format)

        self.musicalContextBlock = musicalContextBlock
        self.outputEventBlock = outputEventBlock
        self.transportStateBlock = transportStateBlock
    }

    func deallocateRenderResources() {
        musicalContextBlock = nil
        outputEventBlock = nil
        transportStateBlock = nil
        pcmBuffer = nil
        audioBufferList = nil
    }

    var renderBlock: AUInternalRenderBlock {
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

extension InstrumentManager {
    func setParameter(address: AUParameterAddress, value: AUValue) {
        instrument.setParameter(address: address, value: value)
    }

    func getParameter(address: AUParameterAddress) -> AUValue {
        return instrument.getParameter(address: address)
    }

    var channelCapabilities: [Int] {
        return instrument.channelCapabilities
    }
}
