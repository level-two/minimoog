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
#import "MinimoogInstrumentObjcWrapper.h"
#include "MinimoogInstrument.hpp"

@interface MinimoogInstrumentObjcWrapper () {
    // Instrument core - C++ class instance
    MinimoogInstrument        _minimoogInstrument;
}

    @property (nonatomic, copy) AUHostMusicalContextBlock musicalContext;
    @property (nonatomic, copy) AUMIDIOutputEventBlock    outputEventBlock;
    @property (nonatomic, copy) AUHostTransportStateBlock transportStateBlock;

    @property (nonatomic) AVAudioFormat*         audioFormat;
    @property (nonatomic) AVAudioChannelCount    maxChannels;

    @property (nonatomic) AVAudioPCMBuffer*      pcmBuffer;
    @property (nonatomic) const AudioBufferList* audioBufferList;
@end

@implementation MinimoogInstrumentObjcWrapper
    @synthesize musicalContext;
    @synthesize outputEventBlock;
    @synthesize transportStateBlock;
    @synthesize audioFormat;
    @synthesize maxChannels;
    @synthesize pcmBuffer;
    @synthesize audioBufferList;

- (id)init {
    return [self initWithAudioFormat:[[AVAudioFormat alloc] initStandardFormatWithSampleRate:44100 channels:2]
                         maxChannels:2];
}

- (id)initWithAudioFormat:(AVAudioFormat*)audioFormat maxChannels:(AVAudioChannelCount) maxChannels;
{
    if (self = [super init]) {
        self.audioFormat = audioFormat;
        self.maxChannels = maxChannels;
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
    return _minimoogInstrument.allocateRenderResources(audioBufferList);
}

- (void)deallocateRenderResources {
    musicalContext      = nil;
    outputEventBlock    = nil;
    transportStateBlock = nil;
    pcmBuffer           = nil;
    audioBufferList     = nil;
    _minimoogInstrument.deallocateRenderResources();
}

- (void)setParameter:(AUParameterAddress) address value:(AUValue) value {
    _minimoogInstrument.setParameter(address, value);
}

- (AUValue)getParameter:(AUParameterAddress) address {
    return _minimoogInstrument.getParameter(address);
}

- (void)setSampleRate:(double)sampleRate {
    return _minimoogInstrument.setSampleRate(sampleRate);
}

- (AUInternalRenderBlock)internalRenderBlock {
    /*
     Capture in locals to avoid ObjC member lookups. If "self" is captured in
     render, we're doing it wrong.
     */
    __block MinimoogInstrument *minimoogInstrumentCapture = &_minimoogInstrument;
    AUHostMusicalContextBlock musicalContextCapture       = musicalContext;
    AUMIDIOutputEventBlock    outputEventBlockCapture     = outputEventBlock;
    AUHostTransportStateBlock transportStateBlockCapture  = transportStateBlock;
    __block BOOL transportStateIsMoving = NO;
    
    return ^AUAudioUnitStatus(AudioUnitRenderActionFlags* actionFlags           ,
                              const AudioTimeStamp*       timestamp             ,
                              AVAudioFrameCount           frameCount            ,
                              NSInteger                   outputBusNumber       ,
                              AudioBufferList*            outputData            ,
                              const AURenderEvent*        realtimeEventListHead ,
                              AURenderPullInputBlock      pullInputBlock        ) {
        double currentTempo = 120.0;
        
        if (musicalContextCapture) {
            double    timeSignatureNumerator;
            NSInteger timeSignatureDenominator;
            double    currentBeatPosition;
            NSInteger sampleOffsetToNextBeat;
            double    currentMeasureDownbeatPosition;
            
            if (musicalContextCapture(&currentTempo, &timeSignatureNumerator, &timeSignatureDenominator,
                                &currentBeatPosition, &sampleOffsetToNextBeat, &currentMeasureDownbeatPosition ) ) {
                //minimoogInstrumentCapture->setTempo(currentTempo);
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
        
        minimoogInstrumentCapture->render(actionFlags, timestamp, frameCount, outputBusNumber,
                                          outputData, realtimeEventListHead, pullInputBlock);
        return noErr;
    };
}

@end
