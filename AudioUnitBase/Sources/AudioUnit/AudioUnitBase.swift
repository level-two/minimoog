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

import AudioToolbox
import AVFoundation

final class AudioUnitBase: AUAudioUnit {
    fileprivate var instrumentManager: InstrumentManager
    fileprivate var curParameterTree: AUParameterTree
    fileprivate var factoryPresetsManager = FactoryPresetsManager()
    fileprivate var curPresetIndex = 0 // Positive - factory, negative - user
    fileprivate var curPresetName = ""

    private var inputBus: AUAudioUnitBus?
    private var outputBus: AUAudioUnitBus

    private lazy var curInputBusses: AUAudioUnitBusArray = {
        let buses = [inputBus].compactMap { $0 }
        return AUAudioUnitBusArray(audioUnit: self, busType: .input, busses: buses)
    }()

    private lazy var curOutputBusses: AUAudioUnitBusArray = {
        return AUAudioUnitBusArray(audioUnit: self, busType: .output, busses: [outputBus])
    }()

    override public var parameterTree: AUParameterTree {
        return self.curParameterTree
    }

    override public var inputBusses: AUAudioUnitBusArray {
        return self.curInputBusses
    }

    override public var outputBusses: AUAudioUnitBusArray {
        return self.curOutputBusses
    }

    override public var internalRenderBlock: AUInternalRenderBlock {
        return instrumentManager.renderBlock
    }

    init(with instrument: Instrument,
         componentDescription: AudioComponentDescription,
         options: AudioComponentInstantiationOptions = []) throws {

        guard let defaultFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 44100,
                                                channels: 2, interleaved: false) else {
            throw AudioUnitError.invalidDefaultAudioFormat
        }

        // inputBus = try AUAudioUnitBus(format: defaultFormat)
        outputBus = try AUAudioUnitBus(format: defaultFormat)
        curParameterTree = AUParameterTree.createTree(withChildren: instrument.parameters)
        instrumentManager = InstrumentManager(instrument: instrument)

        try super.init(componentDescription: componentDescription, options: options)

        currentPreset = AUAudioUnitPreset(with: factoryPresetsManager.defaultPreset())
        setParameterTreeObservers()
    }

    override public func allocateRenderResources() throws {
        try super.allocateRenderResources()
        try instrumentManager.allocateRenderResources(format: outputBus.format,
                                                      maxFrames: self.maximumFramesToRender,
                                                      musicalContextBlock: self.musicalContextBlock,
                                                      outputEventBlock: self.midiOutputEventBlock,
                                                      transportStateBlock: self.transportStateBlock)
    }

    override public func deallocateRenderResources() {
        super.deallocateRenderResources()
        instrumentManager.deallocateRenderResources()
    }
}

extension AudioUnitBase {
    override public var factoryPresets: [AUAudioUnitPreset]? {
        return factoryPresetsManager.allPresets().compactMap { AUAudioUnitPreset(with: $0) }
    }

    override public var fullState: [String: Any]? {
        get {
            let preset = Preset(index: curPresetIndex, name: curPresetName, parameters: curParameterTree.allParameters)
            return preset.fullState
        }
        
        set {
            let preset = Preset(with: newValue)
            curParameterTree.allParameters.forEach { param in
                guard let val = preset.presetValue(for: param.identifier) else { return }
                param.value = val
            }
        }
    }

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
                curPresetName = factoryPreset.name
                curParameterTree.allParameters.forEach { param in
                    guard let val = factoryPreset.presetValue(for: param.identifier) else { return }
                    param.value = val
                }
            }
        }
    }
}

fileprivate extension AudioUnitBase {
    func setParameterTreeObservers() {
//        curParameterTree.implementorValueObserver = { [weak self] param, value in
//            self?.instrumentManager.setParameter(address: param.address, value: value)
//        }

        curParameterTree.implementorValueProvider = { [weak self] param in
            return self?.instrumentManager.getParameter(address: param.address) ?? AUValue(0)
        }

        curParameterTree.implementorStringFromValueCallback = { param, valuePtr in
            let value = valuePtr?.pointee ?? param.value

            if param.unit == .indexed, let strings = param.valueStrings, Int(value) < strings.count {
                return strings[Int(value)]
            } else {
                return String(format: ".2", value)
            }
        }
    }
}
