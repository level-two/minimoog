//
//  MinimoogInstrumentAudioUnit.m
//
//  Created by Yauheni Lychkouski on 10/6/18.
//  Copyright © 2018 Yauheni Lychkouski. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "MinimoogInstrumentAudioUnit.h"
#include "MinimoogInstrument.hpp"

@interface MinimoogInstrumentAudioUnit () {
    // Context
    AUHostMusicalContextBlock _musicalContext;
    AUMIDIOutputEventBlock    _outputEventBlock;
    AUHostTransportStateBlock _transportStateBlock;

    // Buses
    AUAudioUnitBus           *_inputBus;
    AUAudioUnitBus           *_outputBus;
    AUAudioUnitBusArray      *_inputBusArray;
    AUAudioUnitBusArray      *_outputBusArray;

    // Presets
    AUAudioUnitPreset *_currentPreset;
    NSInteger _currentFactoryPresetIndex;
    NSArray<AUAudioUnitPreset *> *_presets;

    // Instrument core - C++ class instance
    MinimoogInstrument        _minimoogInstrument;
}

    @property (nonatomic, readwrite) AUParameterTree *parameterTree;
@end

    // Presets
    static const UInt8 kNumberOfPresets = 12;
    static const NSInteger kDefaultFactoryPreset = 0;

    typedef struct FactoryPresetParameters {
        AUValue intervalValue;
    } FactoryPresetParameters;


    static const FactoryPresetParameters presetParameters[kNumberOfPresets] = {
        { 1 },
        { 2 },
        { 3 },
        { 4 },
        { 5 },
        { 6 },
        { 7 },
        { 8 },
        { 9 },
        { 10 },
        { 11 },
        { 12 },
    };


@implementation MinimoogInstrumentAudioUnit
    @synthesize parameterTree  = _parameterTree;
    @synthesize factoryPresets = _presets;

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
    _minimoogInstrument.setSampleRate(defaultFormat.sampleRate);
    
    //_audioStreamBasicDescription = *defaultFormat.streamDescription;
    // create the busses with this asbd.
    _inputBus       = [[AUAudioUnitBus alloc] initWithFormat:defaultFormat error:nil];
    _outputBus      = [[AUAudioUnitBus alloc] initWithFormat:defaultFormat error:nil];
    _inputBusArray  = [[AUAudioUnitBusArray alloc] initWithAudioUnit:self
                                                             busType:AUAudioUnitBusTypeInput busses: @[_inputBus]];
    _outputBusArray = [[AUAudioUnitBusArray alloc] initWithAudioUnit:self
                                                             busType:AUAudioUnitBusTypeOutput busses: @[_outputBus]];
    
    __block MinimoogInstrument *instr = &_minimoogInstrument;
    _parameterTree.implementorValueObserver = ^(AUParameter *param, AUValue value) {
        instr->setParameter(param.address, value);
    };
    _parameterTree.implementorValueProvider = ^(AUParameter * _Nonnull param) {
        return instr->getParameter(param.address);
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

// ---------------------------------------------
-(NSString*)factoryPresetFilePath {
    NSString *pathString = [[NSBundle mainBundle] pathForResource:@"Profile" ofType:@"plist"];
    return pathString;
}

-(NSString*)userPresetFilePath {
    NSArray  *pathArray  = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *pathString = [[pathArray objectAtIndex:0] stringByAppendingPathComponent:@"data"];
    return pathString;
}

-()loadFactoryPresets {
    NSString          *path       = [self factoryPresetFilePath];
    NSMutableData     *pData      = [[NSMutableData alloc] initWithContentsOfFile:path];
    NSKeyedUnarchiver *unArchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:pData];
    NSDictionary<NSString*, id> *factoryPresetsDic = [[NSDictionary alloc] initWithCoder:unArchiver];
    [unArchiver finishDecoding];
    
    int presetsNumber = [[factoryPresetsDic valueForKey:@"presetsNumber"] integerValue];
    int defaultPresetIndex = [[factoryPresetsDic valueForKey:@"defaultPresetIndex"] integerValue];
    
    
    
    
    
    state[@"fullStateParams"] = [NSKeyedArchiver archivedDataWithRootObject: params];
    
    
    NSDictionary<NSString*, id> *params = @{
                                            @"intervalParameter": [NSNumber numberWithInt: intervalParam.value],
                                            };
    
    AUParameter *cutoffParameter    = [self.parameterTree valueForKey: @"cutoff"];
    cutoffParameter.value    = presetParameters[factoryPreset.number].cutoffValue;
    
    
    
    
    
    
    
    
    _currentFactoryPresetIndex = kDefaultFactoryPreset;
    _presets = @[
                 [self createPreset:0 name:@"Minor Second"],
                 [self createPreset:1 name:@"Major Second"],
                 [self createPreset:2 name:@"Minor Third"],
                 [self createPreset:3 name:@"Major Third"],
                 [self createPreset:4 name:@"Fourth"],
                 [self createPreset:5 name:@"Tritone"],
                 [self createPreset:6 name:@"Fifth"],
                 [self createPreset:7 name:@"Minor Sixth"],
                 [self createPreset:8 name:@"Major Sixth"],
                 [self createPreset:9 name:@"Minor Seventh"],
                 [self createPreset:10 name:@"Major Seventh"],
                 [self createPreset:11 name:@"Octave"]
                 ];
    _currentPreset = self.factoryPresets[_currentFactoryPresetIndex];
}


-(void)saveProfile  {
    SeccionItem *data = [[SeccionItem alloc]init]
    data.title        = @"title";
    data.texto        = @"fdgdf";
    data.images       = [NSArray arrayWithObjects:@"dfds", nil];
    
    NSMutableData   *pData    = [[NSMutableData alloc]init];
    NSString        *path     = [self saveFilePath];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:pData];
    [data encodeWithCoder:archiver];
    [archiver finishEncoding];
    [pData writeToFile:path atomically:YES];
}





- (AUAudioUnitPreset*)createPreset:(NSInteger)number name:(NSString*)name {
    AUAudioUnitPreset* newPreset = [AUAudioUnitPreset new];
    newPreset.number = number;
    newPreset.name = name;
    return newPreset;
}

- (AUAudioUnitPreset *)currentPreset {
    if (_currentPreset.number >= 0) {
        NSLog(@"Returning Current Factory Preset: %ld\n", (long)_currentFactoryPresetIndex);
        return [_presets objectAtIndex:_currentFactoryPresetIndex];
    } else {
        NSLog(@"Returning Current Custom Preset: %ld, %@\n", (long)_currentPreset.number, _currentPreset.name);
        return _currentPreset;
    }
}

- (void)setCurrentPreset:(AUAudioUnitPreset *)currentPreset {
    if (nil == currentPreset) {
        NSLog(@"nil passed to setCurrentPreset!");
        return;
    }
    
    if (currentPreset.number >= 0) {
        // factory preset
        for (AUAudioUnitPreset *factoryPreset in _presets) {
            if (currentPreset.number == factoryPreset.number) {
                AUParameter *cutoffParameter    = [self.parameterTree valueForKey: @"cutoff"];
                AUParameter *resonanceParameter = [self.parameterTree valueForKey: @"resonance"];
                
                cutoffParameter.value    = presetParameters[factoryPreset.number].cutoffValue;
                resonanceParameter.value = presetParameters[factoryPreset.number].resonanceValue;
                
                // set factory preset as current
                _currentPreset             = currentPreset;
                _currentFactoryPresetIndex = factoryPreset.number;
                NSLog(@"currentPreset Factory: %ld, %@\n", (long)_currentFactoryPresetIndex, factoryPreset.name);
                
                break;
            }
        }
    } else if (nil != currentPreset.name) {
        // set custom preset as current
        _currentPreset = currentPreset;
        NSLog(@"currentPreset Custom: %ld, %@\n", (long)_currentPreset.number, _currentPreset.name);
    } else {
        NSLog(@"setCurrentPreset not set! - invalid AUAudioUnitPreset\n");
    }
}

- (NSDictionary<NSString *,id> *)fullState {
    NSLog(@"calling: %s", __PRETTY_FUNCTION__ );
    NSMutableDictionary *state = [[NSMutableDictionary alloc] initWithDictionary: super.fullState];

    // you can do just a setObject:forKey on state, but in real life you will probably have many parameters.
    // so, add a param dictionary to fullState.
    NSDictionary<NSString*, id> *params = @{
                                            @"intervalParameter": [NSNumber numberWithInt: intervalParam.value],
                                            };
    

    state[@"fullStateParams"] = [NSKeyedArchiver archivedDataWithRootObject: params];
    
    return state;
}

- (void)setFullState:(NSDictionary<NSString *,id> *)fullState {
    NSLog(@"calling: %s", __PRETTY_FUNCTION__ );
    NSData *data         = (NSData *)fullState[@"fullStateParams"];
    NSDictionary *params = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    intervalParam.value  = [(NSNumber *)params[@"intervalParameter"] intValue];
}

// ---------------------------------------------

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
