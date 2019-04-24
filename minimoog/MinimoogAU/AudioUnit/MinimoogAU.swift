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

import AVFoundation

extension String: Error { }

public class MinimoogAU: AUAudioUnit {
    // MARK: Types
    enum ParameterId: AUParameterAddress, CaseIterable {
        case osc1Range = 0
        case osc1Waveform
        case osc2Range
        case osc2Detune
        case osc2Waveform
        case mixOsc1Volume
        case mixOsc2Volume
        case mixNoiseVolume
    }

    typealias AUParameterDescription = (String, String, ParameterId, Float, Float, AudioUnitParameterUnit, [String]?)

    // MARK: Overrided properties
    override public var currentPreset: AUAudioUnitPreset? {
        get {
            if curPresetIndex < 0 {
                let userPreset = AUAudioUnitPreset()
                userPreset.number = curPresetIndex
                userPreset.name   = curPresetName
                return userPreset
            } else {
                return AUAudioUnitPreset(with: factoryPresetsManager.getPreset(withIndex: curPresetIndex))
            }
        }
        set {
            guard let newVal = newValue else { return }
            curPresetIndex = newVal.number

            if curPresetIndex < 0 {
                // Parameters will be updated using fullState
                curPresetName = newVal.name
            } else if let factoryPreset = factoryPresetsManager.getPreset(withIndex: curPresetIndex) {
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

    override public var fullState: [String: Any]? {
        get {
            let preset = MinimoogAUPreset(presetIndex: curPresetIndex, presetName: curPresetName, parameters: parameterTree.allParameters)
            return preset.fullState
        }
        set {
            let preset = MinimoogAUPreset(with: newValue)
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

    override public var inputBusses: AUAudioUnitBusArray {
        get { return self.curInputBusses }
        set { self.curInputBusses = newValue }
    }

    override public var outputBusses: AUAudioUnitBusArray {
        get { return self.curOutputBusses }
        set { self.curOutputBusses = newValue }
    }

    override public var internalRenderBlock: AUInternalRenderBlock {
        get { return self.minimoogInstrumentWrapper.internalRenderBlock() }
    }

    // MARK: Private variables
    private let paramsDescription: [AUParameterDescription] = [
        ("osc1Range", "Oscillator 1 Range", .osc1Range, 0, 5, .indexed, ["LO", "32'", "16'", "8'", "4'", "2'"]),
        ("osc1Waveform", "Oscillator 1 Waveform", .osc1Waveform, 0, 5, .indexed, ["Triangle", "Ramp", "Sawtooth", "Square", "Pulse1", "Pulse2"]),
        ("osc2Range", "Oscillator 2 Range", .osc2Range, 0, 5, .indexed, ["LO", "32'", "16'", "8'", "4'", "2'"]),
        ("osc2Detune", "Oscillator 2 Detune", .osc2Detune, -8, 8, .cents, nil),
        ("osc2Waveform", "Oscillator 2 Waveform", .osc2Waveform, 0, 5, .indexed, ["Triangle", "Ramp", "Sawtooth", "Square", "Pulse1", "Pulse2"]),
        ("mixOsc1Volume", "Mixer Oscillator 1 Volume", .mixOsc1Volume, 0, 10, .customUnit, nil),
        ("mixOsc2Volume", "Mixer Oscillator 2 Volume", .mixOsc2Volume, 0, 10, .customUnit, nil),
        ("mixNoiseVolume", "Mixer Noise Volume", .mixNoiseVolume, 0, 10, .customUnit, nil)]

    private var minimoogInstrumentWrapper: MinimoogObjcWrapper
    private var curParameterTree: AUParameterTree!
    private var curInputBusses: AUAudioUnitBusArray!
    private var curOutputBusses: AUAudioUnitBusArray!
    private var factoryPresetsManager: MinimoogAUFactoryPresetsManager

    private var curPresetIndex: Int // Positive - factory, negative - user
    private var curPresetName: String

    // MARK: Methods
    override init(componentDescription: AudioComponentDescription, options: AudioComponentInstantiationOptions = []) throws {
        // -- Set class own properties --
        self.minimoogInstrumentWrapper = MinimoogObjcWrapper()
        self.factoryPresetsManager     = MinimoogAUFactoryPresetsManager()
        self.curPresetIndex            = 0
        self.curPresetName             = ""

        try super.init(componentDescription: componentDescription, options: options)

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

        guard let defaultFormat = AVAudioFormat(standardFormatWithSampleRate: 44100.0, channels: 2) else {
            throw "Invalid audio format"
        }

        //_audioStreamBasicDescription = *defaultFormat.streamDescription
        let inputBus      = try AUAudioUnitBus(format: defaultFormat)
        let outputBus     = try AUAudioUnitBus(format: defaultFormat)
        self.inputBusses  = AUAudioUnitBusArray(audioUnit: self, busType: .input, busses: [inputBus])
        self.outputBusses = AUAudioUnitBusArray(audioUnit: self, busType: .output, busses: [outputBus])

        // -- Customization and final setup --
        self.minimoogInstrumentWrapper.setSampleRate(defaultFormat.sampleRate)

        // A function to provide string representations of parameter values.
        self.parameterTree.implementorStringFromValueCallback = { param, valuePtr in
            let value = (valuePtr == nil ? param.value : valuePtr!.pointee)
            if (param.unit == .indexed) {
                return param.valueStrings![Int(value)]
            } else {
                return String(format: ".2", value)
            }
        }

        // observe parameters change and update synth core
        self.parameterTree.implementorValueObserver = { [weak self] param, value in
            self?.minimoogInstrumentWrapper.setParameter(param.address, value: value)
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
