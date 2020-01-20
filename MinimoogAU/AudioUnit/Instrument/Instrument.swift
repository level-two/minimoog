//
//  Instrument.swift
//  MinimoogAU
//
//  Created by Yauheni Lychkouski on 10/1/19.
//  Copyright © 2019 Yauheni Lychkouski. All rights reserved.
//

import Foundation
import AVFoundation

final class Instrument {
    fileprivate let module: Module
    fileprivate let audioFormat: AVAudioFormat
    fileprivate var musicalContextBlock: AUHostMusicalContextBlock?
    fileprivate var transportStateBlock: AUHostTransportStateBlock?
    fileprivate var outputEventBlock: AUMIDIOutputEventBlock?
    // fileprivate var transportStateIsMoving: Bool = false
    fileprivate var audioBufferList: UnsafeMutableAudioBufferListPointer?
    fileprivate var pcmBuffer: AVAudioPCMBuffer?

    init(audioFormat: AVAudioFormat, module: Module) {
        self.audioFormat = audioFormat
        self.module = module
    }

    func allocateRenderResources(musicalContextBlock: AUHostMusicalContextBlock?,
                                 outputEventBlock: AUMIDIOutputEventBlock?,
                                 transportStateBlock: AUHostTransportStateBlock?,
                                 maxFrames: AVAudioFrameCount) throws {
        self.pcmBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: maxFrames)
        self.pcmBuffer?.frameLength = maxFrames
        self.audioBufferList = UnsafeMutableAudioBufferListPointer(self.pcmBuffer?.mutableAudioBufferList)

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

    func setParameter(address: AUParameterAddress, value: AUValue) {
        module.setParameter(address: address, value: value)
    }

    func getParameter(address: AUParameterAddress) -> AUValue {
        return module.getParameter(address: address)
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

fileprivate extension Instrument {

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
            module.render(leftSample: leftSamplePtr, rightSample: rightSamplePtr)
        }

    }

    func perform(event: AURenderEvent) {
        switch (event.head.eventType) {
        case .parameter:
            let paramEvent = event.parameter
            setParameter(address: paramEvent.parameterAddress, value: paramEvent.value)
        case .parameterRamp:
            let paramEvent = event.parameter
//            startRamp(paramEvent.parameterAddress, paramEvent.value, paramEvent.rampDurationSampleFrames)
            break
        case .MIDI:
//            handleMIDIEvent(event.MIDI)
            break
        default:
            break
        }
    }
}
