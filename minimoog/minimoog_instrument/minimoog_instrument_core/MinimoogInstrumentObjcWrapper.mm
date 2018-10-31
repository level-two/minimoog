//
//  MinimoogInstrumentObjcWrapper.m
//
//  Created by Yauheni Lychkouski on 10/6/18.
//  Copyright © 2018 Yauheni Lychkouski. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "MinimoogInstrumentObjcWrapper.h"
#include "MinimoogInstrument.hpp"

@interface MinimoogInstrumentObjcWrapper () {
    // Instrument core - C++ class instance
    AUHostMusicalContextBlock _musicalContext;
    AUMIDIOutputEventBlock    _outputEventBlock;
    AUHostTransportStateBlock _transportStateBlock;
    MinimoogInstrument        _minimoogInstrument;
}
@end

@implementation MinimoogInstrumentObjcWrapper
- (id)init {
    if (self = [super init]) {
        return self;
    }
    return self;
}


- (BOOL)allocateRenderResourcesWithMusicalContext:(AUHostMusicalContextBlock) musicalContext
                                 outputEventBlock:(AUMIDIOutputEventBlock)    outputEventBlock
                              transportStateBlock:(AUHostTransportStateBlock) transportStateBlock {
    _musicalContext      = musicalContext;
    _outputEventBlock    = outputEventBlock;
    _transportStateBlock = transportStateBlock;
    return _minimoogInstrument.allocateRenderResources();
}

- (void)deallocateRenderResources {
    _musicalContext      = nil;
    _outputEventBlock    = nil;
    _transportStateBlock = nil;
    _minimoogInstrument.deallocateRenderResources();
}

- (void)setParameter:(AUParameterAddress) address value:(AUValue) value {
    _minimoogInstrument.setParameter(address, value);
}

- (AUValue)getParameter:(AUParameterAddress) address {
    return _minimoogInstrument.getParameter(address);
}

- (AUInternalRenderBlock)internalRenderBlock {
    /*
     Capture in locals to avoid ObjC member lookups. If "self" is captured in
     render, we're doing it wrong.
     */
    __block MinimoogInstrument *minimoogInstrumentCapture = &_minimoogInstrument;
    AUHostMusicalContextBlock musicalContextCapture       = _musicalContext;
    AUMIDIOutputEventBlock    outputEventBlockCapture     = _outputEventBlock;
    AUHostTransportStateBlock transportStateBlockCapture  = _transportStateBlock;
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
