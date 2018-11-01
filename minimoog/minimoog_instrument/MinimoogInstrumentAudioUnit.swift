//
//  MinimoogInstrumentAudioUnit.m
//
//  Created by Yauheni Lychkouski on 10/6/18.
//  Copyright © 2018 Yauheni Lychkouski. All rights reserved.
//

import AVFoundation

extension String : Error { }

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
    private var minimoogInstrumentWrapper: MinimoogInstrumentObjcWrapper
    private var curParameterTree: AUParameterTree?
    private var curInputBusses : AUAudioUnitBusArray?
    private var curOutputBusses : AUAudioUnitBusArray?
    
    override public var parameterTree: AUParameterTree? {
        get { return self.curParameterTree }
        set { self.curParameterTree = newValue }
    }
    
    override public var inputBusses : AUAudioUnitBusArray {
        get { return self.curInputBusses! }
        set { self.curInputBusses = newValue }
    }
    
    override public var outputBusses : AUAudioUnitBusArray {
        get { return self.curOutputBusses! }
        set { self.curOutputBusses = newValue }
    }
    
    override public var internalRenderBlock : AUInternalRenderBlock {
        get { return self.minimoogInstrumentWrapper.internalRenderBlock() }
    }
    
    private func createParam(
          _   identifier: String,
          _         name: String,
          _      address: ParamAddr,
          _          min: Float,
          _          max: Float,
          _         unit: AudioUnitParameterUnit,
          _ valueStrings: [String] = []) -> AUParameter {
        return AUParameterTree.createParameter(
            withIdentifier:identifier,
            name:name,
            address:address.rawValue,
            min:AUValue(min),
            max:AUValue(max),
            unit:unit,
            unitName:nil,
            flags:[.flag_IsWritable, .flag_IsReadable],
            valueStrings:(valueStrings.isEmpty ? nil : valueStrings),
            dependentParameters:nil)
    }
    
    override init(componentDescription: AudioComponentDescription, options: AudioComponentInstantiationOptions = []) throws {
        minimoogInstrumentWrapper = MinimoogInstrumentObjcWrapper()
        
        try super.init(componentDescription:componentDescription, options:options)
        
        // Create parameter objects
        let params = [
            createParam("osc1Range"     ,"Oscillator 1 Range"       , .osc1RangeParamAddr     ,  0,  5, .indexed, ["LO","32'","16'","8'","4'","2'"]),
            createParam("osc1Waveform"  ,"Oscillator 1 Waveform"    , .osc1WaveformParamAddr  ,  0,  5, .indexed, ["Triangle","Ramp","Sawtooth","Square","Pulse1","Pulse2"]),
            createParam("osc2Range"     ,"Oscillator 2 Range"       , .osc2RangeParamAddr     ,  0,  5, .indexed, ["LO","32'","16'","8'","4'","2'"]),
            createParam("osc2Detune"    ,"Oscillator 2 Detune"      , .osc2DetuneParamAddr    , -8,  8, .cents),
            createParam("osc2Waveform"  ,"Oscillator 2 Waveform"    , .osc2WaveformParamAddr  ,  0,  5, .indexed, ["Triangle","Ramp","Sawtooth","Square","Pulse1","Pulse2"]),
            createParam("mixOsc1Volume" ,"Mixer Oscillator 1 Volume", .mixOsc1VolumeParamAddr ,  0, 10, .customUnit),
            createParam("mixOsc2Volume" ,"Mixer Oscillator 2 Volume", .mixOsc2VolumeParamAddr ,  0, 10, .customUnit),
            createParam("mixNoiseVolume","Mixer Noise Volume"       , .mixNoiseVolumeParamAddr,  0, 10, .customUnit)]
        
        // Create the parameter tree.
        self.parameterTree = AUParameterTree.createTree(withChildren: params)

        // A function to provide string representations of parameter values.
        self.parameterTree!.implementorStringFromValueCallback = { param, valuePtr in
            let value = (valuePtr == nil ? param.value : valuePtr!.pointee)
            if (param.unit == .indexed) {
                return param.valueStrings![Int(value)]
            }
            else {
                return String(format:".2", value)
            }
        }
        
        // Create the output bus.
        let defaultFormat = AVAudioFormat(standardFormatWithSampleRate:44100.0, channels:2)
        self.minimoogInstrumentWrapper.setSampleRate(defaultFormat!.sampleRate)
        
        //_audioStreamBasicDescription = *defaultFormat.streamDescription
        // create the busses with this asbd.
        let inputBus      = try AUAudioUnitBus(format:defaultFormat!)
        let outputBus     = try AUAudioUnitBus(format:defaultFormat!)
        self.inputBusses  = AUAudioUnitBusArray(audioUnit:self, busType:.input, busses: [inputBus])
        self.outputBusses = AUAudioUnitBusArray(audioUnit:self, busType:.output, busses: [outputBus])
        
        // observe parameters change and update synth core
        self.parameterTree!.implementorValueObserver = { [weak self] param, value in
            guard let strongSelf = self else { return }
            strongSelf.minimoogInstrumentWrapper.setParameter(param.address, value:value)
        }

        self.parameterTree!.implementorValueProvider = { [weak self] param in
            guard let strongSelf = self else { return AUValue(0) }
            return strongSelf.minimoogInstrumentWrapper.getParameter(param.address)
        }
        
        self.maximumFramesToRender = 512
    }

    // MARK: - AUAudioUnit Overrides
    override public func allocateRenderResources() throws {
        try super.allocateRenderResources()
        let result = self.minimoogInstrumentWrapper.allocateRenderResources(musicalContext: self.musicalContextBlock,
                                                                            outputEventBlock:self.midiOutputEventBlock,
                                                                            transportStateBlock:self.transportStateBlock)
        guard result else { throw "Failed to allocate render resources" }
    }

    override public func deallocateRenderResources() {
        super.deallocateRenderResources()
        minimoogInstrumentWrapper.deallocateRenderResources()
    }

    // MARK: - AUAudioUnit (AUAudioUnitImplementation)
    func getFactoryPresetFilePath() -> String? {
        return Bundle.main.path(forResource:"Profile", ofType:"plist")
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

}

