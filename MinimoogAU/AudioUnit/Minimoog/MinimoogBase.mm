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


#import "MinimoogBase.hpp"
#import <algorithm>

MinimoogBase::MinimoogBase() {
    m_audioBufferList = nullptr;
}

MinimoogBase::~MinimoogBase() {
}

bool MinimoogBase::allocateRenderResources(const AudioBufferList* audioBufferList) {
    m_audioBufferList = audioBufferList;
    return doAllocateRenderResources();
}

void MinimoogBase::deallocateRenderResources() {
    m_audioBufferList = nullptr;
    doDeallocateRenderResources();
}

void MinimoogBase::render(AudioUnitRenderActionFlags* actionFlags          ,
                          const AudioTimeStamp*       timestamp            ,
                          AUAudioFrameCount           frameCount           ,
                          NSInteger                   outputBusNumber      ,
                          AudioBufferList*            outputData           ,
                          const AURenderEvent*        realtimeEventListHead,
                          AURenderPullInputBlock      pullInputBlock       )
{
    prepareOutputBufferList(outputData, frameCount, true);
    
    AUEventSampleTime now             = AUEventSampleTime(timestamp->mSampleTime);
    AUAudioFrameCount framesRemaining = frameCount;
    AURenderEvent const *event        = realtimeEventListHead;
    
    while (framesRemaining > 0) {
        // If there are no more events, we can process the entire remaining segment and exit
        if (event == nullptr) {
            AUAudioFrameCount const bufferOffset = frameCount - framesRemaining;
            renderSegmentFrames(framesRemaining, outputData, bufferOffset);
            break;
        }
        
        // **** start late events late
        auto timeZero = AUEventSampleTime(0);
        auto headEventTime = event->head.eventSampleTime;
        AUAudioFrameCount const framesThisSegment = AUAudioFrameCount(std::max(timeZero, headEventTime - now));
        
        // Compute everything before the next event.
        if (framesThisSegment > 0) {
            AUAudioFrameCount const bufferOffset = frameCount - framesRemaining;
            renderSegmentFrames(framesThisSegment, outputData, bufferOffset);
            
            // Advance frames.
            framesRemaining -= framesThisSegment;
            
            // Advance time.
            now += AUEventSampleTime(framesThisSegment);
        }
        
        performAllSimultaneousEvents(now, event);
    }
}

void MinimoogBase::prepareOutputBufferList(AudioBufferList* outBufferList, AVAudioFrameCount frameCount, bool zeroFill) {
    UInt32 byteSize = frameCount * sizeof(float);
    
    for (UInt32 i = 0; i < outBufferList->mNumberBuffers; ++i) {
        outBufferList->mBuffers[i].mNumberChannels = m_audioBufferList->mBuffers[i].mNumberChannels;
        outBufferList->mBuffers[i].mDataByteSize = byteSize;
        
        if (outBufferList->mBuffers[i].mData == nullptr) {
            outBufferList->mBuffers[i].mData = m_audioBufferList->mBuffers[i].mData;
        }
        
        if (zeroFill) {
            memset(outBufferList->mBuffers[i].mData, 0, byteSize);
        }
    }
}

void MinimoogBase::renderSegmentFrames(AUAudioFrameCount       frameCount  ,
                                       AudioBufferList*        outputData  ,
                                       AUAudioFrameCount const bufferOffset)
{
    for (int i = 0; i < frameCount; i++) {
        float* outL = (float*)outputData->mBuffers[0].mData + bufferOffset + i;
        float* outR = (float*)outputData->mBuffers[1].mData + bufferOffset + i;
        doRender(outL, outR);
    }
}

void MinimoogBase::performAllSimultaneousEvents(AUEventSampleTime now, AURenderEvent const *&event) {
    do {
        switch (event->head.eventType) {
            case AURenderEventParameter: {
                AUParameterEvent const& paramEvent = event->parameter;
                setParameter(paramEvent.parameterAddress, paramEvent.value);
                break;
            }
            case AURenderEventParameterRamp: {
                AUParameterEvent const& paramEvent = event->parameter;
                startRamp(paramEvent.parameterAddress, paramEvent.value, paramEvent.rampDurationSampleFrames);
                break;
            }
            case AURenderEventMIDI:
                handleMIDIEvent(event->MIDI);
                break;
            default:
                break;
        }
        event = event->head.next;
    } while (event && event->head.eventSampleTime <= now);
}
