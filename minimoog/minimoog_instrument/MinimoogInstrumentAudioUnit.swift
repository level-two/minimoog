//
//  MinimoogInstrumentAudioUnit.m
//
//  Created by Yauheni Lychkouski on 10/6/18.
//  Copyright © 2018 Yauheni Lychkouski. All rights reserved.
//

import AVFoundation

extension String : Error { }

public class MinimoogInstrumentAudioUnit : AUAudioUnit {
    // MARK: Types
    enum ParamAddr : AUParameterAddress, CaseIterable {
        case osc1RangeParamAddr = 0
        case osc1WaveformParamAddr
        case osc2RangeParamAddr
        case osc2DetuneParamAddr
        case osc2WaveformParamAddr
        case mixOsc1VolumeParamAddr
        case mixOsc2VolumeParamAddr
        case mixNoiseVolumeParamAddr
    }
    
    typealias AUParameterDescription = (String, String, ParamAddr, Float, Float, AudioUnitParameterUnit, [String]?)
    
    // MARK: Overrided properties
    override public var currentPreset: AUAudioUnitPreset? {
        get {
            if curPresetIndex < 0 {
                let userPreset = AUAudioUnitPreset()
                userPreset.number = curPresetIndex
                userPreset.name   = curPresetName
                return userPreset
            }
            else {
                return AUAudioUnitPreset(with: factoryPresetsManager.getPreset(withIndex: curPresetIndex))
            }
        }
        set {
            guard let newVal = newValue else { return }
            curPresetIndex = newVal.number
            
            if curPresetIndex < 0 {
                // Parameters will be updated using fullState
                curPresetName = newVal.name
            }
            else if let factoryPreset = factoryPresetsManager.getPreset(withIndex: curPresetIndex) {
                curPresetName = factoryPreset.presetName
                parameterTree.allParameters.forEach { param in
                    guard let val = factoryPreset.presetValue(for: param.identifier) else { return }
                    param.value = val
                }
            }
        }
    }
    
    override public var factoryPresets: [AUAudioUnitPreset]? {
        get {
            return factoryPresetsManager.allPresets().compactMap { AUAudioUnitPreset(with: $0) }
        }
    }
    
    override public var fullState: [String:Any]? {
        get {
            let preset = MinimoogInstrumentPreset(presetIndex: curPresetIndex, presetName: curPresetName, parameters: parameterTree.allParameters)
            return preset.fullState
        }
        set {
            let preset = MinimoogInstrumentPreset(with: newValue)
            parameterTree.allParameters.forEach { param in
                guard let val = preset.presetValue(for: param.identifier) else { return }
                param.value = val
            }
        }
    }
    
    override public var parameterTree: AUParameterTree {
        get { return self.curParameterTree }
        set { self.curParameterTree = newValue }
    }
    
    override public var inputBusses : AUAudioUnitBusArray {
        get { return self.curInputBusses }
        set { self.curInputBusses = newValue }
    }
    
    override public var outputBusses : AUAudioUnitBusArray {
        get { return self.curOutputBusses }
        set { self.curOutputBusses = newValue }
    }
    
    override public var internalRenderBlock : AUInternalRenderBlock {
        get { return self.minimoogInstrumentWrapper.internalRenderBlock() }
    }
    
    // MARK: Private variables
    private let paramsDescription : [AUParameterDescription] = [
        ("osc1Range"     ,"Oscillator 1 Range"       , .osc1RangeParamAddr     ,  0,  5, .indexed, ["LO","32'","16'","8'","4'","2'"]),
        ("osc1Waveform"  ,"Oscillator 1 Waveform"    , .osc1WaveformParamAddr  ,  0,  5, .indexed, ["Triangle","Ramp","Sawtooth","Square","Pulse1","Pulse2"]),
        ("osc2Range"     ,"Oscillator 2 Range"       , .osc2RangeParamAddr     ,  0,  5, .indexed, ["LO","32'","16'","8'","4'","2'"]),
        ("osc2Detune"    ,"Oscillator 2 Detune"      , .osc2DetuneParamAddr    , -8,  8, .cents  , nil),
        ("osc2Waveform"  ,"Oscillator 2 Waveform"    , .osc2WaveformParamAddr  ,  0,  5, .indexed, ["Triangle","Ramp","Sawtooth","Square","Pulse1","Pulse2"]),
        ("mixOsc1Volume" ,"Mixer Oscillator 1 Volume", .mixOsc1VolumeParamAddr ,  0, 10, .customUnit, nil),
        ("mixOsc2Volume" ,"Mixer Oscillator 2 Volume", .mixOsc2VolumeParamAddr ,  0, 10, .customUnit, nil),
        ("mixNoiseVolume","Mixer Noise Volume"       , .mixNoiseVolumeParamAddr,  0, 10, .customUnit, nil)]
    
    private var minimoogInstrumentWrapper: MinimoogInstrumentObjcWrapper
    private var curParameterTree         : AUParameterTree!
    private var curInputBusses           : AUAudioUnitBusArray!
    private var curOutputBusses          : AUAudioUnitBusArray!
    private var factoryPresetsManager    : MinimoogInstrumentFactoryPresetsManager
    
    private var curPresetIndex           : Int // Positive - factory, negative - user
    private var curPresetName            : String
    
    // MARK: Methods
    override init(componentDescription: AudioComponentDescription, options: AudioComponentInstantiationOptions = []) throws {
        // -- Set class own properties --
        self.minimoogInstrumentWrapper = MinimoogInstrumentObjcWrapper()
        self.factoryPresetsManager     = MinimoogInstrumentFactoryPresetsManager()
        self.curPresetIndex            = 0
        self.curPresetName             = ""
        
        try super.init(componentDescription:componentDescription, options:options)
        
        // -- Set inherited and overriden properties --
        self.maximumFramesToRender = 512
        
        let params = paramsDescription.map { description in
            AUParameterTree.createParameter(withIdentifier: description.0,
                                                      name: description.1,
                                                   address: description.2.rawValue,
                                                       min: AUValue(description.3),
                                                       max: AUValue(description.4),
                                                      unit: description.5,
                                                  unitName: nil,
                                                     flags: [.flag_IsWritable, .flag_IsReadable],
                                              valueStrings: description.6,
                                       dependentParameters: nil)
        }
        self.parameterTree = AUParameterTree.createTree(withChildren: params)
        
        guard let defaultFormat = AVAudioFormat(standardFormatWithSampleRate:44100.0, channels:2) else {
            throw "Invalid audio format"
        }
        
        //_audioStreamBasicDescription = *defaultFormat.streamDescription
        let inputBus      = try AUAudioUnitBus(format:defaultFormat)
        let outputBus     = try AUAudioUnitBus(format:defaultFormat)
        self.inputBusses  = AUAudioUnitBusArray(audioUnit:self, busType:.input, busses: [inputBus])
        self.outputBusses = AUAudioUnitBusArray(audioUnit:self, busType:.output, busses: [outputBus])
        
        // -- Customization and final setup --
        self.minimoogInstrumentWrapper.setSampleRate(defaultFormat.sampleRate)
        
        // A function to provide string representations of parameter values.
        self.parameterTree.implementorStringFromValueCallback = { param, valuePtr in
            let value = (valuePtr == nil ? param.value : valuePtr!.pointee)
            if (param.unit == .indexed) {
                return param.valueStrings![Int(value)]
            }
            else {
                return String(format:".2", value)
            }
        }
        
        // observe parameters change and update synth core
        self.parameterTree.implementorValueObserver = { [weak self] param, value in
            self?.minimoogInstrumentWrapper.setParameter(param.address, value:value)
        }
        
        self.parameterTree.implementorValueProvider = { [weak self] param in
            return self?.minimoogInstrumentWrapper.getParameter(param.address) ?? AUValue(0)
        }
        
        // apply default preset
        self.currentPreset = AUAudioUnitPreset(with: self.factoryPresetsManager.defaultPreset())
    }

    // MARK: AUAudioUnit Overrides
    override public func allocateRenderResources() throws {
        try super.allocateRenderResources()
        guard self.minimoogInstrumentWrapper.allocateRenderResources(musicalContext: self.musicalContextBlock ,
                                                                   outputEventBlock: self.midiOutputEventBlock,
                                                                transportStateBlock: self.transportStateBlock ,
                                                                          maxFrames: self.maximumFramesToRender)
        else { throw "Failed to allocate render resources" }
    }

    override public func deallocateRenderResources() {
        super.deallocateRenderResources()
        self.minimoogInstrumentWrapper.deallocateRenderResources()
    }
}
