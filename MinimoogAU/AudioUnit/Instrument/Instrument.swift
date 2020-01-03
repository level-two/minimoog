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
    var audioFormat: AVAudioFormat?

    fileprivate var musicalContext: AUHostMusicalContextBlock?
    fileprivate var transportState: AUHostTransportStateBlock?
    fileprivate var outputEvent: AUMIDIOutputEventBlock?
    fileprivate var pcmBuffer: AVAudioPCMBuffer?
    // fileprivate var audioBufferList: UnsafePointer<AudioBufferList>
    fileprivate var transportStateIsMoving: Bool = false

//    init(with audioFormat: AVAudioFormat) {
//        self.audioFormat = audioFormat
        // TODO instrument.setSampleRate(audioFormat.sampleRate)
//    }

    func allocateRenderResources() throws {
        
    }

    func deallocateRenderResources() {
        musicalContext = nil
        outputEvent = nil
        transportState = nil
        pcmBuffer = nil
        //audioBufferList = nil
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

            guard let self = self else { return kAudioUnitErr_Uninitialized }

//            self.prepareOutputBufferList(outputData, frameCount, true)
//
//            let now = AUEventSampleTime(timestamp.mSampleTime)
//            let event = realtimeEventListHead
//            var framesRemaining = frameCount
//
//            while framesRemaining > 0 {
//                // If there are no more events, we can process the entire remaining segment and exit
//                if event == nullptr {
//                    let bufferOffset = frameCount - framesRemaining
//                    self.renderSegmentFrames(framesRemaining, outputData, bufferOffset)
//                    break
//                }
//
//                // **** start late events late
//                let timeZero = AUEventSampleTime(0)
//                let headEventTime = event.head.eventSampleTime
//                let framesThisSegment = AUAudioFrameCount(max(timeZero, headEventTime - now))
//
//                // Compute everything before the next event.
//                if framesThisSegment > 0 {
//                    let bufferOffset = frameCount - framesRemaining
//                    self.renderSegmentFrames(framesThisSegment, outputData, bufferOffset)
//
//                    // Advance frames.
//                    framesRemaining -= framesThisSegment
//
//                    // Advance time.
//                    now += AUEventSampleTime(framesThisSegment)
//                }
//
//                self.performAllSimultaneousEvents(now, event)
//            }

            return noErr
        }
    }
}

extension Instrument {
    fileprivate func prepareOutputBufferList(outBufferList: inout AudioBufferList,
                                             frameCount: AVAudioFrameCount,
                                             zeroFill: Bool) {
//        let byteSize = frameCount * sizeOf(Float.self)
//
//        for idx in [0 ..< outBufferList.mNumberBuffers] {
//            outBufferList.mBuffers[idx].mNumberChannels = m_audioBufferList.mBuffers[idx].mNumberChannels
//            outBufferList.mBuffers[idx].mDataByteSize = byteSize
//
//            if outBufferList.mBuffers[idx].mData == nullptr {
//                outBufferList.mBuffers[idx].mData = m_audioBufferList.mBuffers[i].mData
//            }
//
//            if zeroFill {
//                memset(outBufferList.mBuffers[i].mData, 0, byteSize)
//            }
//        }
    }

    fileprivate func renderSegmentFrames(frameCount: AUAudioFrameCount,
                                         outputData: AudioBufferList,
                                         bufferOffset: AUAudioFrameCount) {
//        for idx in [0 ..< frameCount] {
//            float* outL = (float*)outputData.mBuffers[0].mData + bufferOffset + idx
//            float* outR = (float*)outputData.mBuffers[1].mData + bufferOffset + ikdx
//            doRender(outL, outR)
//        }
    }

    fileprivate func performAllSimultaneousEvents(now: AUEventSampleTime, event: AURenderEvent) {
//        repeat {
//            switch (event.head.eventType) {
//            case .parameter:
//                let paramEvent = event.parameter
//                setParameter(paramEvent.parameterAddress, paramEvent.value)
//            case .parameterRamp:
//                let paramEvent = event.parameter
//                startRamp(paramEvent.parameterAddress, paramEvent.value, paramEvent.rampDurationSampleFrames)
//            case .MIDI:
//                handleMIDIEvent(event.MIDI)
//            default:
//                break
//            }
//            event = event.head.next
//        } while (event && event.head.eventSampleTime <= now)
    }
}
