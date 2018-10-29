//
//  MinimoogInstrumentAudioUnit.m
//
//  Created by Yauheni Lychkouski on 10/6/18.
//  Copyright © 2018 Yauheni Lychkouski. All rights reserved.
//

import AVFoundation

public class MinimoogInstrumentAudioUnit : AUAudioUnit {
    // Context
    var musicalContext: AUHostMusicalContextBlock
    var outputEventBlock: AUMIDIOutputEventBlock
    var transportStateBlock: AUHostTransportStateBlock

    // Presets
    var currentPreset: AUAudioUnitPreset
    var currentFactoryPresetIndex: NSInteger
    var presets: [AUAudioUnitPreset]

    // Instrument core
    var minimoogInstrumentWrapper: MinimoogInstrumentObjcWrapper 


    override func init(componentDescription: AudioComponentDescription, 
            options: AudioComponentInstantiationOptions = []) throws {
        super.init(componentDescription:componentDescription, options:options)
        
        // Create parameter objects.
        /*
        var params = [NSMutableArray array]
        int i = 0
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
                 dependentParameters:nil]
            
            // Initialize the parameter values.
            param.value = paramDef[i].initVal
            [params addObject:param]
            
            _minimoogInstrument.setParameter(paramDef[i].paramAddr, paramDef[i].initVal)
            
            i++
        }
        */
        let params = [AUParameter]
        
        // Create the parameter tree.
        _parameterTree = AUParameterTree.createTreeWithChildren(params)
        
        /*
        // A function to provide string representations of parameter values.
        _parameterTree.implementorStringFromValueCallback = ^(AUParameter *param, const AUValue *__nullable valuePtr) {
            AUValue value = valuePtr == nil ? param.value : *valuePtr
            if (param.address >= lastParamAddr) {
                return @"?"
            }
            else if (paramDef[param.address].unit == kAudioUnitParameterUnit_Indexed) {
                return param.valueStrings[(UInt32)param.value]
            }
            else {
                return [NSString stringWithFormat:@"%.2f", value]
            }
        }
        */
        
        // Create the output bus.
        let defaultFormat = AVAudioFormat(standardFormatWithSampleRate:44100.0, channels:2)
        self.minimoogInstrument.setSampleRate(defaultFormat.sampleRate)
        
        //_audioStreamBasicDescription = *defaultFormat.streamDescription
        // create the busses with this asbd.
        var inputBus    = AUAudioUnitBus(format:defaultFormat, error:nil)
        var outputBus   = AUAudioUnitBus(format:defaultFormat, error:nil)
        self.inputBues  = AUAudioUnitBusArray(audioUnit:self, busType:AUAudioUnitBusTypeInput, busses: @[inputBus])
        self.outputBues = AUAudioUnitBusArray(audioUnit:self, busType:AUAudioUnitBusTypeOutput, busses: @[outputBus])
        
        /*
        __block MinimoogInstrument *instr = &_minimoogInstrument
        _parameterTree.implementorValueObserver = ^(AUParameter *param, AUValue value) {
            instr->setParameter(param.address, value)
        }
        _parameterTree.implementorValueProvider = ^(AUParameter * _Nonnull param) {
            return instr->getParameter(param.address)
        }
        */
        
        self.maximumFramesToRender = 512
    }

    // MARK: - AUAudioUnit Overrides
    override func allocateRenderResources() throws {
        super.allocateRenderResources()
        minimoogInstrumentWrapper.allocateRenderResources()
    }

    override func deallocateRenderResources() {
        super.deallocateRenderResources()
        minimoogInstrumentWrapper.allocateRenderResources()
    }

    // MARK: - AUAudioUnit (AUAudioUnitImplementation)
    func getFactoryPresetFilePath() -> String {
        NSString *pathString = [[NSBundle mainBundle] pathForResource:@"Profile" ofType:@"plist"]
        return pathString
    }

    func loadFactoryPresets() {
        /*
        NSString          *path       = [self factoryPresetFilePath]
        NSMutableData     *pData      = [[NSMutableData alloc] initWithContentsOfFile:path]
        NSKeyedUnarchiver *unArchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:pData]
        NSDictionary<NSString*, id> *factoryPresetsDic = [[NSDictionary alloc] initWithCoder:unArchiver]
        [unArchiver finishDecoding]
        
        int presetsNumber = [[factoryPresetsDic valueForKey:@"presetsNumber"] integerValue]
        int defaultPresetIndex = [[factoryPresetsDic valueForKey:@"defaultPresetIndex"] integerValue]
        
        
        
        
        
        state[@"fullStateParams"] = [NSKeyedArchiver archivedDataWithRootObject: params]
        
        
        NSDictionary<NSString*, id> *params = @{
                                                @"intervalParameter": [NSNumber numberWithInt: intervalParam.value],
                                                }
        
        AUParameter *cutoffParameter    = [self.parameterTree valueForKey: @"cutoff"]
        cutoffParameter.value    = presetParameters[factoryPreset.number].cutoffValue
        
        
        _currentFactoryPresetIndex = kDefaultFactoryPreset
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
                     ]
        _currentPreset = self.factoryPresets[_currentFactoryPresetIndex]
        */
    }


    func saveProfile() {
        /*
        SeccionItem *data = [[SeccionItem alloc]init]
        data.title        = @"title"
        data.texto        = @"fdgdf"
        data.images       = [NSArray arrayWithObjects:@"dfds", nil]
        
        NSMutableData   *pData    = [[NSMutableData alloc]init]
        NSString        *path     = [self saveFilePath]
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:pData]
        [data encodeWithCoder:archiver]
        [archiver finishEncoding]
        [pData writeToFile:path atomically:YES]
        */
    }





    /*
    func createPreset((NSInteger)number name:(NSString*)name -> AUAudioUnitPreset{
        AUAudioUnitPreset* newPreset = [AUAudioUnitPreset new]
        newPreset.number = number
        newPreset.name = name
        return newPreset
    }

    func currentPreset -> AUAudioUnitPreset {
        if (_currentPreset.number >= 0) {
            NSLog(@"Returning Current Factory Preset: %ld\n", (long)_currentFactoryPresetIndex)
            return [_presets objectAtIndex:_currentFactoryPresetIndex]
        } else {
            NSLog(@"Returning Current Custom Preset: %ld, %@\n", (long)_currentPreset.number, _currentPreset.name)
            return _currentPreset
        }
    }

    func setCurrentPreset:(AUAudioUnitPreset *)currentPreset{
        if (nil == currentPreset) {
            NSLog(@"nil passed to setCurrentPreset!")
            return
        }
        
        if (currentPreset.number >= 0) {
            // factory preset
            for (AUAudioUnitPreset *factoryPreset in _presets) {
                if (currentPreset.number == factoryPreset.number) {
                    AUParameter *cutoffParameter    = [self.parameterTree valueForKey: @"cutoff"]
                    AUParameter *resonanceParameter = [self.parameterTree valueForKey: @"resonance"]
                    
                    cutoffParameter.value    = presetParameters[factoryPreset.number].cutoffValue
                    resonanceParameter.value = presetParameters[factoryPreset.number].resonanceValue
                    
                    // set factory preset as current
                    _currentPreset             = currentPreset
                    _currentFactoryPresetIndex = factoryPreset.number
                    NSLog(@"currentPreset Factory: %ld, %@\n", (long)_currentFactoryPresetIndex, factoryPreset.name)
                    
                    break
                }
            }
        } else if (nil != currentPreset.name) {
            // set custom preset as current
            _currentPreset = currentPreset
            NSLog(@"currentPreset Custom: %ld, %@\n", (long)_currentPreset.number, _currentPreset.name)
        } else {
            NSLog(@"setCurrentPreset not set! - invalid AUAudioUnitPreset\n")
        }
    }

    // Methods for user presets storing and loading
    func fullState() -> [String:AnyObject]{
        NSLog(@"calling: %s", __PRETTY_FUNCTION__ )
        NSMutableDictionary *state = [[NSMutableDictionary alloc] initWithDictionary: super.fullState]

        // you can do just a setObject:forKey on state, but in real life you will probably have many parameters.
        // so, add a param dictionary to fullState.
        NSDictionary<NSString*, id> *params = @{
                                                @"intervalParameter": [NSNumber numberWithInt: intervalParam.value],
                                                }
        state[@"fullStateParams"] = [NSKeyedArchiver archivedDataWithRootObject: params]
        
        return state
    }

    func setFullState(_:[String:AnyObject] fullState) {
        NSLog(@"calling: %s", __PRETTY_FUNCTION__ )
        NSData *data         = (NSData *)fullState[@"fullStateParams"]
        NSDictionary *params = [NSKeyedUnarchiver unarchiveObjectWithData:data]
        intervalParam.value  = [(NSNumber *)params[@"intervalParameter"] intValue]
    }
    */

    // ---------------------------------------------
    func internalRenderBlock -> AUInternalRenderBlock {
        return minimoogInstrument.internalRenderBlock
    }
}

