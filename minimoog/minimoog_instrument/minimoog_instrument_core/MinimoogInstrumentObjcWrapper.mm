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
    MinimoogInstrument _minimoogInstrument;
}
@end

@implementation MinimoogInstrumentObjcWrapper
    @synthesize musicalContext;
    @synthesize outputEventBlock;
    @synthesize transportStateBlock;


- (id)init {
    if (self = [super init]) {
        return self;
    }
    return self;
}

- (BOOL)allocateRenderResourcesAndReturnError:(NSError **)outError {
    //self.musicalContextBlock
    //self.MIDIOutputEventBlock
    //self.transportStateBlock
    return _minimoogInstrument.allocateRenderResources();
}

- (void)deallocateRenderResources {
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
    __block MinimoogInstrument *instr = &_minimoogInstrument;
    
    return ^AUAudioUnitStatus(AudioUnitRenderActionFlags* actionFlags           ,
                              const AudioTimeStamp*       timestamp             ,
                              AVAudioFrameCount           frameCount            ,
                              NSInteger                   outputBusNumber       ,
                              AudioBufferList*            outputData            ,
                              const AURenderEvent*        realtimeEventListHead ,
                              AURenderPullInputBlock      pullInputBlock        ) {
        instr->render(actionFlags, timestamp, frameCount, outputBusNumber,
                      outputData, realtimeEventListHead, pullInputBlock);
        return noErr;
    };
}

@end
