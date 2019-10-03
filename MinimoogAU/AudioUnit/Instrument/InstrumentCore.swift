//
//  File.swift
//  MinimoogAU
//
//  Created by Yauheni Lychkouski on 10/1/19.
//  Copyright © 2019 Yauheni Lychkouski. All rights reserved.
//

import Foundation

class InstrumentCore {
    init(topModule: Module) {
        self.module = topModule
    }

    public func allocateRenderResources(audioBufferList: AudioBufferList) -> Bool {
        self.audioBufferList = audioBufferList
        return module.allocateRenderResources()
    }

    public func deallocateRenderResources() {
        m_audioBufferList = nullptr
        doDeallocateRenderResources()
    }

    public func render(actionFlags: AudioUnitRenderActionFlags,
                timestamp: AudioTimeStamp,
                frameCount: AUAudioFrameCount,
                outputBusNumber: Int,
                outputData: AudioBufferList,
                realtimeEventListHead: AURenderEvent,
                pullInputBlock: AURenderPullInputBlock) {
        prepareOutputBufferList(outputData, frameCount, true)

        AUEventSampleTime now             = AUEventSampleTime(timestamp.mSampleTime)
        AUAudioFrameCount framesRemaining = frameCount
        AURenderEvent const *event        = realtimeEventListHead

        while (framesRemaining > 0) {
            // If there are no more events, we can process the entire remaining segment and exit
            if (event == nullptr) {
                AUAudioFrameCount const bufferOffset = frameCount - framesRemaining
                renderSegmentFrames(framesRemaining, outputData, bufferOffset)
                break
            }

            // **** start late events late
            auto timeZero = AUEventSampleTime(0)
            auto headEventTime = event.head.eventSampleTime
            AUAudioFrameCount const framesThisSegment = AUAudioFrameCount(std::max(timeZero, headEventTime - now))

            // Compute everything before the next event.
            if (framesThisSegment > 0) {
                AUAudioFrameCount const bufferOffset = frameCount - framesRemaining
                renderSegmentFrames(framesThisSegment, outputData, bufferOffset)

                // Advance frames.
                framesRemaining -= framesThisSegment

                // Advance time.
                now += AUEventSampleTime(framesThisSegment)
            }

            performAllSimultaneousEvents(now, event)
        }
    }

    fileprivate let module: Module
    fileprivate var audioBufferList: AudioBufferList?
}

extension InstrumentCore {
    fileprivate func prepareOutputBufferList(outBufferList: AudioBufferList, frameCount: AVAudioFrameCount, zeroFill: Bool) {
        UInt32 byteSize = frameCount * sizeof(float)

        for (UInt32 i = 0 i < outBufferList.mNumberBuffers ++i) {
            outBufferList.mBuffers[i].mNumberChannels = m_audioBufferList.mBuffers[i].mNumberChannels
            outBufferList.mBuffers[i].mDataByteSize = byteSize

            if (outBufferList.mBuffers[i].mData == nullptr) {
                outBufferList.mBuffers[i].mData = m_audioBufferList.mBuffers[i].mData
            }

            if (zeroFill) {
                memset(outBufferList.mBuffers[i].mData, 0, byteSize)
            }
        }
    }

    fileprivate func renderSegmentFrames(frameCount: AUAudioFrameCount,
                             outputData: AudioBufferList,
                             bufferOffset: AUAudioFrameCount) {
        for (int i = 0 i < frameCount i++) {
            float* outL = (float*)outputData.mBuffers[0].mData + bufferOffset + i
            float* outR = (float*)outputData.mBuffers[1].mData + bufferOffset + i
            doRender(outL, outR)
        }
    }

    fileprivate func performAllSimultaneousEvents(now: AUEventSampleTime, event: AURenderEvent) {
        do {
            switch (event.head.eventType) {
            case AURenderEventParameter: {
                AUParameterEvent const& paramEvent = event.parameter
                setParameter(paramEvent.parameterAddress, paramEvent.value)
                break
                }
            case AURenderEventParameterRamp: {
                AUParameterEvent const& paramEvent = event.parameter
                startRamp(paramEvent.parameterAddress, paramEvent.value, paramEvent.rampDurationSampleFrames)
                break
                }
            case AURenderEventMIDI:
                handleMIDIEvent(event.MIDI)
                break
            default:
                break
            }
            event = event.head.next
        } while (event && event.head.eventSampleTime <= now)
    }
}

