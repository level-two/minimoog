//
//  MinimoogInstrumentAudioUnit.m
//
//  Created by Yauheni Lychkouski on 10/6/18.
//  Copyright © 2018 Yauheni Lychkouski. All rights reserved.
//

#import "MinimoogInstrumentAudioUnit.h"
#include "MinimoogInstrument.hpp"

#import <AVFoundation/AVFoundation.h>


@interface MinimoogInstrumentAudioUnit () {
    AUHostMusicalContextBlock _musicalContext;
    AUMIDIOutputEventBlock _outputEventBlock;
    AUHostTransportStateBlock _transportStateBlock;
    
    AUAudioUnitBus *_inputBus;
    AUAudioUnitBus *_outputBus;
    AUAudioUnitBusArray *_inputBusArray;
    AUAudioUnitBusArray *_outputBusArray;
    AUParameterTree *_parameterTree;
    
    MinimoogInstrument _minimoogInstrument;
}
@end


@implementation MinimoogInstrumentAudioUnit

- (instancetype)initWithComponentDescription:(AudioComponentDescription)componentDescription options:(AudioComponentInstantiationOptions)options error:(NSError **)outError {
    self = [super initWithComponentDescription:componentDescription options:options error:outError];
    
    if (self == nil) {
        return nil;
    }
    
    // Create parameter objects.
    NSMutableArray *params = [NSMutableArray array];
    int i = 0;
    while (paramDef[i].paramAddr < lastParamAddr) {
        AUParameter *param =
            [AUParameterTree
             createParameterWithIdentifier:[NSString stringWithUTF8String:paramDef[i].identifier]
             name:[NSString stringWithUTF8String:paramDef[i].name]
             address:paramDef[i].paramAddr
             min:paramDef[i].min
             max:paramDef[i].max
             unit:paramDef[i].unit
             unitName:nil
             flags:0
             valueStrings:[[NSString stringWithUTF8String:paramDef[i].commaSeparatedIndexedNames] componentsSeparatedByString:@","]
             dependentParameters:nil];
        
        // Initialize the parameter values.
        param.value = paramDef[i].initVal;
        [params addObject:param];
        
        _minimoogInstrument.setParameter(paramDef[i].paramAddr, paramDef[i].initVal);
        
        i++;
    }
    
    // Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:params];
    
    // A function to provide string representations of parameter values.
    _parameterTree.implementorStringFromValueCallback = ^(AUParameter *param, const AUValue *__nullable valuePtr) {
        AUValue value = valuePtr == nil ? param.value : *valuePtr;
        if (param.address >= lastParamAddr) {
            return @"?";
        }
        else if (paramDef[param.address].unit == kAudioUnitParameterUnit_Indexed) {
            return param.valueStrings[(UInt32)param.value];
        }
        else {
            return [NSString stringWithFormat:@"%.2f", value];
        }
    };
    
    
    // Create the output bus.
    AVAudioFormat *defaultFormat = [[AVAudioFormat alloc] initStandardFormatWithSampleRate:44100. channels:2];
    
    //_audioStreamBasicDescription = *defaultFormat.streamDescription;
    
    // create the busses with this asbd.
    _inputBus = [[AUAudioUnitBus alloc] initWithFormat:defaultFormat error:nil];
    _outputBus = [[AUAudioUnitBus alloc] initWithFormat:defaultFormat error:nil];
    
    // Create the input and output bus arrays.
    _inputBusArray  = [[AUAudioUnitBusArray alloc] initWithAudioUnit:self
                                                             busType:AUAudioUnitBusTypeInput busses: @[_inputBus]];
    
    _outputBusArray = [[AUAudioUnitBusArray alloc] initWithAudioUnit:self
                                                             busType:AUAudioUnitBusTypeOutput busses: @[_outputBus]];
    
    // Make a local pointer to the kernel to avoid capturing self.
    __block MinimoogInstrument *minimoogInstrument = &_minimoogInstrument;
    
    // implementorValueObserver is called when a parameter changes value.
    _parameterTree.implementorValueObserver = ^(AUParameter *param, AUValue value) {
        minimoogInstrument->setParameter(param.address, value);
    };
    
    // implementorValueProvider is called when the value needs to be refreshed.
    _parameterTree.implementorValueProvider = ^(AUParameter * _Nonnull param) {
        return minimoogInstrument->getParameter(param.address);
    };
    
    self.maximumFramesToRender = 512;
    
    return self;
}

#pragma mark - AUAudioUnit Overrides
- (AUAudioUnitBusArray *)inputBusses {
    return _inputBusArray;
}

- (AUAudioUnitBusArray *)outputBusses {
    return _outputBusArray;
}

- (BOOL)allocateRenderResourcesAndReturnError:(NSError **)outError {
    if (![super allocateRenderResourcesAndReturnError:outError]) {
        return NO;
    }
    
    // Validate that the bus formats are compatible.
    // Allocate your resources.
    if (self.musicalContextBlock) {
        _musicalContext = self.musicalContextBlock;
    } else {
        _musicalContext = nil;
    }
    
    if (self.MIDIOutputEventBlock) {
        _outputEventBlock = self.MIDIOutputEventBlock;
    } else {
        _outputEventBlock = nil;
    }
    
    if (self.musicalContextBlock) {
        _transportStateBlock = self.transportStateBlock;
    } else {
        _transportStateBlock = nil;
    }
    
    return YES;
}

- (void)deallocateRenderResources {
    [super deallocateRenderResources];
}

#pragma mark - AUAudioUnit (AUAudioUnitImplementation)
- (AUInternalRenderBlock)internalRenderBlock {
    /*
     Capture in locals to avoid ObjC member lookups. If "self" is captured in
     render, we're doing it wrong.
     */
    __block MinimoogInstrument *instr = &_minimoogInstrument;
    
    return ^AUAudioUnitStatus(AudioUnitRenderActionFlags *actionFlags,
                              const AudioTimeStamp       *timestamp,
                              AVAudioFrameCount           frameCount,
                              NSInteger                   outputBusNumber,
                              AudioBufferList            *outputData,
                              const AURenderEvent        *realtimeEventListHead,
                              AURenderPullInputBlock      pullInputBlock) {
        instr->doRender(actionFlags, timestamp, frameCount, outputBusNumber, outputData, realtimeEventListHead, pullInputBlock);
        return noErr;
    };
}

@end
