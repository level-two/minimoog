//
//  Instrument.swift
//  MinimoogAU
//
//  Created by Yauheni Lychkouski on 10/1/19.
//  Copyright © 2019 Yauheni Lychkouski. All rights reserved.
//

import Foundation
import AVFoundation

class Instrument {
    enum InstrumentError: Error {
        case audioFormatNotSet
    }

    var audioFormat: AVAudioFormat?
    fileprivate var musicalContextBlock: AUHostMusicalContextBlock?
    fileprivate var transportStateBlock: AUHostTransportStateBlock?
    fileprivate var outputEventBlock: AUMIDIOutputEventBlock?
    // fileprivate var transportStateIsMoving: Bool = false
    fileprivate var audioBufferList: UnsafeMutableAudioBufferListPointer?
    fileprivate var pcmBuffer: AVAudioPCMBuffer? {
        didSet {
            audioBufferList = UnsafeMutableAudioBufferListPointer(self.pcmBuffer?.mutableAudioBufferList)
        }
    }

    func allocateRenderResources(musicalContextBlock: AUHostMusicalContextBlock?,
                                 outputEventBlock: AUMIDIOutputEventBlock?,
                                 transportStateBlock: AUHostTransportStateBlock?,
                                 maxFrames: AVAudioFrameCount) throws {
        guard let audioFormat = audioFormat else {
            throw InstrumentError.audioFormatNotSet
        }
        self.pcmBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: maxFrames)
        self.musicalContextBlock = musicalContextBlock
        self.outputEventBlock = outputEventBlock
        self.transportStateBlock = transportStateBlock
    }

    func deallocateRenderResources() {
        musicalContextBlock = nil
        outputEventBlock = nil
        transportStateBlock = nil
        pcmBuffer = nil
        // TODO instrument.deallocateRenderResources()
    }

    func setParameter(address: AUParameterAddress, value: AUValue) {
        // TODO instrument.setParameter(address, value)
    }

    func getParameter(address: AUParameterAddress) -> AUValue {
        return 0
        // TODO return instrument.getParameter(address)
    }

    var renderBlock: AUInternalRenderBlock {
        return { [weak self] (actionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
                              timestamp: UnsafePointer<AudioTimeStamp>,
                              frameCount: AUAudioFrameCount,
                              outputBusNumber: Int,
                              outputData: UnsafeMutablePointer<AudioBufferList>,
                              realtimeEventListHead:  UnsafePointer<AURenderEvent>?,
                              pullInputBlock:AURenderPullInputBlock?)
                              -> AUAudioUnitStatus in

            guard let self = self,
                let audioBufferList = self.audioBufferList
                else { return kAudioUnitErr_Uninitialized }

            let outBufferList = UnsafeMutableAudioBufferListPointer(outputData)

            self.prepare(outBufferList: outBufferList, using: audioBufferList, zeroFill: false)

            var lastEventTime = AUEventSampleTime(timestamp.pointee.mSampleTime)
            var framesRemaining = frameCount

            var event = realtimeEventListHead?.pointee
            while let curEvent = event {
                let curEventTime = curEvent.head.eventSampleTime
                let framesInSegment = AUAudioFrameCount(curEventTime - lastEventTime)

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

fileprivate extension Instrument {

    func prepare(outBufferList: UnsafeMutableAudioBufferListPointer,
                 using audioBufferList: UnsafeMutableAudioBufferListPointer,
                 zeroFill: Bool) {

        for idx in outBufferList.indices {
            outBufferList[idx].mNumberChannels = audioBufferList[idx].mNumberChannels
            outBufferList[idx].mDataByteSize = audioBufferList[idx].mDataByteSize

            if outBufferList[idx].mData == nil {
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
//        for idx in [0 ..< frameCount] {
//            float* outL = (float*)outputData.mBuffers[0].mData + bufferOffset + idx
//            float* outR = (float*)outputData.mBuffers[1].mData + bufferOffset + ikdx
//            doRender(outL, outR)
//        }
    }

    func perform(event: AURenderEvent) {
        switch (event.head.eventType) {
        case .parameter:
            let paramEvent = event.parameter
            setParameter(address: paramEvent.parameterAddress, value: paramEvent.value)
        case .parameterRamp:
            //let paramEvent = event.parameter
            //startRamp(paramEvent.parameterAddress, paramEvent.value, paramEvent.rampDurationSampleFrames)
            break
        case .MIDI:
            //handleMIDIEvent(event.MIDI)
            break
        default:
            break
        }
    }
}
