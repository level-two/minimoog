//
//  MinimoogInstrumentAudioUnit.m
//
//  Created by Yauheni Lychkouski on 10/6/18.
//  Copyright © 2018 Yauheni Lychkouski. All rights reserved.
//

import AVFoundation

public class MinimoogInstrumentAudioUnit : AUAudioUnit {
    enum ParamAddr : AUParameterAddress {
        case osc1RangeParamAddr = 0
        case osc1WaveformParamAddr
        case osc2RangeParamAddr
        case osc2DetuneParamAddr
        case osc2WaveformParamAddr
        case mixOsc1VolumeParamAddr
        case mixOsc2VolumeParamAddr
        case mixNoiseVolumeParamAddr
    }

    // Instrument core
    var minimoogInstrumentWrapper: MinimoogInstrumentObjcWrapper?

    override init(componentDescription: AudioComponentDescription, options: AudioComponentInstantiationOptions = []) throws {
        super.init(componentDescription:componentDescription, options:options)
        
        var flags = AudioUnitParameterOptions.flag_IsWritable | AudioUnitParameterOptions.flag_IsReadable; 

        // Create parameter objects
        var params = [
            AUParameterTree.createParameter(withIdentifier:"osc1Range"     , name:"Oscillator 1 Range"       , address:osc1RangeParamAddr     , min: 0, max: 5, unit:.indexed   , unitName:nil, flags:flags, valueStrings:["LO","32'","16'","8'","4'","2'"])
            AUParameterTree.createParameter(withIdentifier:"osc1Waveform"  , name:"Oscillator 1 Waveform"    , address:osc1WaveformParamAddr  , min: 0, max: 5, unit:.indexed   , unitName:nil, flags:flags, valueStrings:["Triangle","Ramp","Sawtooth","Square","Pulse1","Pulse2"])
            AUParameterTree.createParameter(withIdentifier:"osc2Range"     , name:"Oscillator 2 Range"       , address:osc2RangeParamAddr     , min: 0, max: 5, unit:.indexed   , unitName:nil, flags:flags, valueStrings:"LO,32',16',8',4',2'"])
            AUParameterTree.createParameter(withIdentifier:"osc2Detune"    , name:"Oscillator 2 Detune"      , address:osc2DetuneParamAddr    , min:-8, max: 8, unit:.cents     , unitName:nil, flags:flags, valueStrings:nil)
            AUParameterTree.createParameter(withIdentifier:"osc2Waveform"  , name:"Oscillator 2 Waveform"    , address:osc2WaveformParamAddr  , min: 0, max: 5, unit:.indexed   , unitName:nil, flags:flags, valueStrings:["Triangle","Ramp","Sawtooth","Square","Pulse1","Pulse2"])
            AUParameterTree.createParameter(withIdentifier:"mixOsc1Volume" , name:"Mixer Oscillator 1 Volume", address:mixOsc1VolumeParamAddr , min: 0, max:10, unit:.customUnit, unitName:nil, flags:flags, valueStrings:nil)
            AUParameterTree.createParameter(withIdentifier:"mixOsc2Volume" , name:"Mixer Oscillator 2 Volume", address:mixOsc2VolumeParamAddr , min: 0, max:10, unit:.customUnit, unitName:nil, flags:flags, valueStrings:nil)
            AUParameterTree.createParameter(withIdentifier:"mixNoiseVolume", name:"Mixer Noise Volume"       , address:mixNoiseVolumeParamAddr, min: 0, max:10, unit:.customUnit, unitName:nil, flags:flags, valueStrings:nil) ]

        
        // Create the parameter tree.
        self.parameterTree = AUParameterTree.createTree(params)

        // A function to provide string representations of parameter values.
        self.parameterTree.implementorStringFromValueCallback = { param, valuePtr in 
            AUValue value = (valuePtr == nil ? param.value : valuePtr.pointee)
            if (param.unit == .indexed) {
                return param.valueStrings[(UInt32)value]
            }
            else {
                return [NSString stringWithFormat:@"%.2f", value]
            }
        }
        
        // Create the output bus.
        let defaultFormat = AVAudioFormat(standardFormatWithSampleRate:44100.0, channels:2)
        self.minimoogInstrument.setSampleRate(defaultFormat.sampleRate)
        
        //_audioStreamBasicDescription = *defaultFormat.streamDescription
        // create the busses with this asbd.
        var inputBus    = AUAudioUnitBus(format:defaultFormat, error:nil)
        var outputBus   = AUAudioUnitBus(format:defaultFormat, error:nil)
        self.inputBues  = AUAudioUnitBusArray(audioUnit:self, busType:AUAudioUnitBusTypeInput, busses: @[inputBus])
        self.outputBues = AUAudioUnitBusArray(audioUnit:self, busType:AUAudioUnitBusTypeOutput, busses: @[outputBus])
        
        // observe parameters change and update synth core
        self.parameterTree.implementorValueObserver = { [weak self] param, value in
            guard let strongSelf = self else { return }
            strongSelf.minimoogInstrumentWrapper.setParameter(param.address, value)
        }

        self.parameterTree.implementorValueProvider = { [weak self] param in
            guard let strongSelf = self else { return }
            return strongSelf.minimoogInstrumentWrapper.getParameter(param.address)
        }
        
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
    func internalRenderBlock() -> AUInternalRenderBlock {
        return minimoogInstrument.internalRenderBlock
    }
}

