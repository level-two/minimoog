//
//  minimoog_instrumentAudioUnit.m
//  minimoog_instrument
//
//  Created by Yauheni Lychkouski on 10/6/18.
//  Copyright © 2018 Yauheni Lychkouski. All rights reserved.
//

#import "minimoog_instrumentAudioUnit.h"

#import <AVFoundation/AVFoundation.h>

// Define parameter addresses.
enum {
    osc1RangeParamId = 0,
    osc1WaveformParamId,
    osc2RangeParamId,
    osc2DetuneParamId,
    osc2WaveformParamId,
    mixOsc1VolumeParamId,
    mixOsc2VolumeParamId,
    mixNoiseVolumeParamId,
    lastParamId = -1
};


typedef struct {
    AudioUnitParameterID paramId;
    const char *identifier;
    const char *name;
    float min;
    float max;
    float initVal;
    AudioUnitParameterUnit unit;
    const char *commaSeparatedIndexedNames;
} ParameterDef;


const ParameterDef paramDef[] = {
    {osc1RangeParamId     , "osc1Range"     , "Oscillator 1 Range"       ,  0,  5,  0, kAudioUnitParameterUnit_Indexed, "LO,32',16',8',4',2'" },
    {osc1WaveformParamId  , "osc1Waveform"  , "Oscillator 1 Waveform"    ,  0,  5,  0, kAudioUnitParameterUnit_Indexed, "Triangle,Ramp,Sawtooth,Square,Pulse1,Pulse2" },
    {osc2RangeParamId     , "osc2Range"     , "Oscillator 2 Range"       ,  0,  5,  0, kAudioUnitParameterUnit_Octaves, "LO,32',16',8',4',2'" },
    {osc2DetuneParamId    , "osc2Detune"    , "Oscillator 2 Detune"      , -8,  8,  0, kAudioUnitParameterUnit_Cents  , "" },
    {osc2WaveformParamId  , "osc2Waveform"  , "Oscillator 2 Waveform"    ,  0,  5,  0, kAudioUnitParameterUnit_Indexed,  "Triangle,Ramp,Sawtooth,Square,Pulse1,Pulse2" },
    {mixOsc1VolumeParamId , "mixOsc1Volume" , "Mixer Oscillator 1 Volume",  0, 10, 10, kAudioUnitParameterUnit_CustomUnit, "" },
    {mixOsc2VolumeParamId , "mixOsc2Volume" , "Mixer Oscillator 2 Volume",  0, 10,  0, kAudioUnitParameterUnit_CustomUnit, "" },
    {mixNoiseVolumeParamId, "mixNoiseVolume", "Mixer Noise Volume"       ,  0, 10,  0, kAudioUnitParameterUnit_CustomUnit, "" },
    {lastParamId}
};


@interface minimoog_instrumentAudioUnit ()
    @property AUAudioUnitBus *outputBus;
    @property AUAudioUnitBusArray *outputBusArray;
    @property (nonatomic, readwrite) AUParameterTree *parameterTree;
@end


@implementation minimoog_instrumentAudioUnit
    @synthesize outputBus;
    @synthesize outputBusArray;
    @synthesize parameterTree;

- (instancetype)initWithComponentDescription:(AudioComponentDescription)componentDescription options:(AudioComponentInstantiationOptions)options error:(NSError **)outError {
    self = [super initWithComponentDescription:componentDescription options:options error:outError];
    
    if (self == nil) {
        return nil;
    }
    
    // Create parameter objects.
    NSMutableArray *params = [NSMutableArray array];
    int i = 0;
    while (paramDef[i].paramId != lastParamId) {
        AUParameter *param =
            [AUParameterTree
             createParameterWithIdentifier:[NSString stringWithUTF8String:paramDef[i].identifier]
             name:[NSString stringWithUTF8String:paramDef[i].name]
             address:paramDef[i].paramId
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
        
        i++;
    }
    
    
    
    
    _kernel.setParameter(InstrumentParamAttack, attackParam.value);
    _kernel.setParameter(InstrumentParamRelease, releaseParam.value);
    
    
    
    
    // Create the parameter tree.
    self.parameterTree = [AUParameterTree createTreeWithChildren:params];
    
    
    
    
    // Create the output bus.
    AVAudioFormat *defaultFormat = [[AVAudioFormat alloc] initStandardFormatWithSampleRate:44100. channels:2];
    self.outputBusBuffer.init(defaultFormat, 2);
    self.outputBus = self.outputBusBuffer.bus;
    
    // Create the input and output bus arrays.
    outputBusArray = [[AUAudioUnitBusArray alloc] initWithAudioUnit:self
                                                            busType:AUAudioUnitBusTypeOutput
                                                             busses: @[outputBus]];
    
    // Make a local pointer to the kernel to avoid capturing self.
    __block InstrumentDSPKernel *instrumentKernel = &_kernel;
    
    // implementorValueObserver is called when a parameter changes value.
    _parameterTree.implementorValueObserver = ^(AUParameter *param, AUValue value) {
        instrumentKernel->setParameter(param.address, value);
    };
    
    // implementorValueProvider is called when the value needs to be refreshed.
    _parameterTree.implementorValueProvider = ^(AUParameter *param) {
        return instrumentKernel->getParameter(param.address);
    };
    
    // A function to provide string representations of parameter values.
    _parameterTree.implementorStringFromValueCallback = ^(AUParameter *param, const AUValue *__nullable valuePtr) {
        AUValue value = valuePtr == nil ? param.value : *valuePtr;
        
        switch (param.address) {
            case InstrumentParamAttack:
            case InstrumentParamRelease:
                return [NSString stringWithFormat:@"%.3f", value];
                
            default:
                return @"?";
        }
    };
    
    
    
    
    
    self.maximumFramesToRender = 512;
    
    return self;
}

#pragma mark - AUAudioUnit Overrides

/*
 Overriding AUAudioUnit Properties and Methods
 You must override the following properties in your AUAudioUnit subclass:
 Override the inputBusses getter method to return the app extension’s audio input connection points.
 Override the outputBusses getter method to return the app extension’s audio output connection points.
 Override the internalRenderBlock getter method to return the block that implements the app extension’s audio rendering loop.
 Also override the allocateRenderResourcesAndReturnError: method, which the host app calls before it starts to render audio, and override the deallocateRenderResources method, which the host app calls after it has finished rendering audio. Within each override, call the AUAudioUnit superclass implementation.
 */





// If an audio unit has input, an audio unit's audio input connection points.
// Subclassers must override this property getter and should return the same object every time.
// See sample code.
- (AUAudioUnitBusArray *)inputBusses {
#warning implementation must return non-nil AUAudioUnitBusArray
    return nil;
}

// An audio unit's audio output connection points.
// Subclassers must override this property getter and should return the same object every time.
// See sample code.
- (AUAudioUnitBusArray *)outputBusses {
#warning implementation must return non-nil AUAudioUnitBusArray
    return nil;
}

// Allocate resources required to render.
// Subclassers should call the superclass implementation.
- (BOOL)allocateRenderResourcesAndReturnError:(NSError **)outError {
    if (![super allocateRenderResourcesAndReturnError:outError]) {
        return NO;
    }
    
    // Validate that the bus formats are compatible.
    // Allocate your resources.
    
    return YES;
}

// Deallocate resources allocated in allocateRenderResourcesAndReturnError:
// Subclassers should call the superclass implementation.
- (void)deallocateRenderResources {
    // Deallocate your resources.
    [super deallocateRenderResources];
}

#pragma mark - AUAudioUnit (AUAudioUnitImplementation)

// Block which subclassers must provide to implement rendering.
- (AUInternalRenderBlock)internalRenderBlock {
    // Capture in locals to avoid Obj-C member lookups. If "self" is captured in render, we're doing it wrong. See sample code.
    
    return ^AUAudioUnitStatus(AudioUnitRenderActionFlags *actionFlags, const AudioTimeStamp *timestamp, AVAudioFrameCount frameCount, NSInteger outputBusNumber, AudioBufferList *outputData, const AURenderEvent *realtimeEventListHead, AURenderPullInputBlock pullInputBlock) {
        // Do event handling and signal processing here.
        
        return noErr;
    };
}

@end

