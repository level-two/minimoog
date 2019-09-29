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

#import <AVFoundation/AVFoundation.h>
#import "MinimoogInstrument.h"
#include "Minimoog.hpp"

@interface MinimoogInstrument () {
    // Instrument core - C++ class instance
    Minimoog instrument;
}

    @property (nonatomic, copy) AUHostMusicalContextBlock musicalContext;
    @property (nonatomic, copy) AUMIDIOutputEventBlock outputEventBlock;
    @property (nonatomic, copy) AUHostTransportStateBlock transportStateBlock;

    @property (nonatomic) AVAudioFormat* audioFormat;

    @property (nonatomic) AVAudioPCMBuffer* pcmBuffer;
    @property (nonatomic) const AudioBufferList* audioBufferList;
@end

@implementation MinimoogInstrument
    @synthesize musicalContext;
    @synthesize outputEventBlock;
    @synthesize transportStateBlock;
    @synthesize audioFormat;
    @synthesize pcmBuffer;
    @synthesize audioBufferList;

- (id)initWithAudioFormat:(AVAudioFormat*)audioFormat
{
    if (self = [super init]) {
        self.audioFormat = audioFormat;
        instrument.setSampleRate(audioFormat.sampleRate);
    }
    return self;
}

- (BOOL)allocateRenderResourcesWithMusicalContext:(AUHostMusicalContextBlock) musicalContext
                                 outputEventBlock:(AUMIDIOutputEventBlock)    outputEventBlock
                              transportStateBlock:(AUHostTransportStateBlock) transportStateBlock
                                        maxFrames:(AVAudioFrameCount)         maxFrames {
    self.musicalContext      = musicalContext;
    self.outputEventBlock    = outputEventBlock;
    self.transportStateBlock = transportStateBlock;
    self.pcmBuffer           = [[AVAudioPCMBuffer alloc] initWithPCMFormat:audioFormat frameCapacity:maxFrames];
    self.audioBufferList     = pcmBuffer.audioBufferList;
    return instrument.allocateRenderResources(audioBufferList);
}

- (void)deallocateRenderResources {
    musicalContext      = nil;
    outputEventBlock    = nil;
    transportStateBlock = nil;
    pcmBuffer           = nil;
    audioBufferList     = nil;
    instrument.deallocateRenderResources();
}

- (void)setParameter:(AUParameterAddress) address value:(AUValue) value {
    instrument.setParameter(address, value);
}

- (AUValue)getParameter:(AUParameterAddress) address {
    return instrument.getParameter(address);
}

- (AUInternalRenderBlock)internalRenderBlock {
    /*
     Capture in locals to avoid ObjC member lookups. If "self" is captured in
     render, we're doing it wrong.
     */
    __block Minimoog *minimoogCapture = &instrument;
    AUHostMusicalContextBlock musicalContextCapture       = musicalContext;
    AUMIDIOutputEventBlock    outputEventBlockCapture     = outputEventBlock;
    AUHostTransportStateBlock transportStateBlockCapture  = transportStateBlock;
    __block BOOL transportStateIsMoving = NO;

    return ^AUAudioUnitStatus(AudioUnitRenderActionFlags* actionFlags,
                              const AudioTimeStamp*       timestamp,
                              AVAudioFrameCount           frameCount,
                              NSInteger                   outputBusNumber,
                              AudioBufferList*            outputData,
                              const AURenderEvent*        realtimeEventListHead,
                              AURenderPullInputBlock      pullInputBlock) {
        double currentTempo = 120.0;
        
        if (musicalContextCapture) {
            double    timeSignatureNumerator;
            NSInteger timeSignatureDenominator;
            double    currentBeatPosition;
            NSInteger sampleOffsetToNextBeat;
            double    currentMeasureDownbeatPosition;
            
            if (musicalContextCapture(&currentTempo, &timeSignatureNumerator, &timeSignatureDenominator,
                                &currentBeatPosition, &sampleOffsetToNextBeat, &currentMeasureDownbeatPosition ) ) {
                //minimoogCapture->setTempo(currentTempo);
                if (transportStateIsMoving) {
                    //NSLog(@"currentBeatPosition %f", currentBeatPosition);
                    // these two seem to always be 0. Probably a host issue.
                    //NSLog(@"sampleOffsetToNextBeat %ld", (long)sampleOffsetToNextBeat);
                    //NSLog(@"currentMeasureDownbeatPosition %f", currentMeasureDownbeatPosition);
                }
            }
        }
        
        if (transportStateBlockCapture) {
            AUHostTransportStateFlags flags;
            double currentSamplePosition;
            double cycleStartBeatPosition;
            double cycleEndBeatPosition;
            
            transportStateBlockCapture(&flags, &currentSamplePosition, &cycleStartBeatPosition, &cycleEndBeatPosition);
            
            if (flags & AUHostTransportStateChanged) {
                //NSLog(@"AUHostTransportStateChanged bit set");
                //NSLog(@"currentSamplePosition %f", currentSamplePosition);
            }
            
            if (flags & AUHostTransportStateMoving) {
                //NSLog(@"AUHostTransportStateMoving bit set");
                //NSLog(@"currentSamplePosition %f", currentSamplePosition);
                transportStateIsMoving = YES;
            } else {
                transportStateIsMoving = NO;
            }
            
            if (flags & AUHostTransportStateRecording) {
                //NSLog(@"AUHostTransportStateRecording bit set");
                //NSLog(@"currentSamplePosition %f", currentSamplePosition);
            }
            
            if (flags & AUHostTransportStateCycling) {
                //NSLog(@"AUHostTransportStateCycling bit set");
                //NSLog(@"currentSamplePosition %f", currentSamplePosition);
                //NSLog(@"cycleStartBeatPosition %f", cycleStartBeatPosition);
                //NSLog(@"cycleEndBeatPosition %f", cycleEndBeatPosition);
            }
        }
        
        minimoogCapture->render(actionFlags, timestamp, frameCount, outputBusNumber,
                                outputData, realtimeEventListHead, pullInputBlock);
        return noErr;
    };
}

@end
