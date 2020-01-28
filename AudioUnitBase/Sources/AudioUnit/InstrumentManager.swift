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
    fileprivate let instrument: Instrument
    fileprivate var musicalContextBlock: AUHostMusicalContextBlock?
    fileprivate var transportStateBlock: AUHostTransportStateBlock?
    fileprivate var outputEventBlock: AUMIDIOutputEventBlock?
    // fileprivate var transportStateIsMoving: Bool = false
    fileprivate var audioBufferList: UnsafeMutableAudioBufferListPointer?
    fileprivate var pcmBuffer: AVAudioPCMBuffer?

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
        // TODO instrument.deallocateRenderResources()
    }

    var renderBlock: AUInternalRenderBlock {
        return { [weak self] (actionFlags, timestamp, frameCount, outputBusNumber,
                              outputData, realtimeEventListHead, pullInputBlock) -> AUAudioUnitStatus in

            guard let self = self, let audioBufferList = self.audioBufferList else { return kAudioUnitErr_Uninitialized }

            let outBufferList = UnsafeMutableAudioBufferListPointer(outputData)
            self.prepare(outBufferList: outBufferList, using: audioBufferList, zeroFill: false)

            var lastEventTime = AUEventSampleTime(timestamp.pointee.mSampleTime)
            var framesRemaining = frameCount
            var event = realtimeEventListHead?.pointee

            while let curEvent = event {
                let curEventTime = curEvent.head.eventSampleTime
                let framesInSegment = AUAudioFrameCount(curEventTime - lastEventTime)

                if framesInSegment > framesRemaining {
                    break
                }

                let bufferOffset = frameCount - framesRemaining
                self.renderFrames(to: outBufferList, framesCount: framesInSegment, startingFrom: bufferOffset)

                self.perform(event: curEvent)

                lastEventTime = curEventTime
                framesRemaining -= framesInSegment
                event = curEvent.head.next?.pointee
            }

            let bufferOffset = frameCount - framesRemaining
            self.renderFrames(to: outBufferList, framesCount: framesRemaining, startingFrom: bufferOffset)

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
}

extension InstrumentManager {
    func prepare(outBufferList: UnsafeMutableAudioBufferListPointer,
                 using audioBufferList: UnsafeMutableAudioBufferListPointer,
                 zeroFill: Bool) {

        for idx in outBufferList.indices {
            if outBufferList[idx].mData == nil {
                outBufferList[idx].mNumberChannels = audioBufferList[idx].mNumberChannels
                outBufferList[idx].mDataByteSize = audioBufferList[idx].mDataByteSize
                outBufferList[idx].mData = audioBufferList[idx].mData
            }

            if zeroFill {
                memset(outBufferList[idx].mData, 0, Int(outBufferList[idx].mDataByteSize))
            }
        }
    }

    func renderFrames(to outBufferList: UnsafeMutableAudioBufferListPointer,
                      framesCount: AUAudioFrameCount,
                      startingFrom bufferOffset: AUAudioFrameCount) {

        guard let leftBufPtr = outBufferList[0].mData?.assumingMemoryBound(to: Float32.self),
            let rightBufPtr = outBufferList[1].mData?.assumingMemoryBound(to: Float32.self)
            else { return }

        for idx in 0..<framesCount {
            let leftSamplePtr = leftBufPtr + Int(bufferOffset + idx)
            let rightSamplePtr = rightBufPtr + Int(bufferOffset + idx)
            instrument.render(leftSample: leftSamplePtr, rightSample: rightSamplePtr)
        }

    }

    func perform(event: AURenderEvent) {
        switch (event.head.eventType) {
        case .parameter:
            let paramEvent = event.parameter
            setParameter(address: paramEvent.parameterAddress, value: paramEvent.value)
        case .parameterRamp:
//            let paramEvent = event.parameter
//            startRamp(paramEvent.parameterAddress, paramEvent.value, paramEvent.rampDurationSampleFrames)
            break
        case .MIDI:
            if let midiEvent = MidiEvent(from: event.MIDI) {
                instrument.handle(midiEvent: midiEvent)
            }
        default:
            break
        }
    }
}
