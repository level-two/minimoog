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
import UIKit

class MinimoogAudioUnit: AUAudioUnit {
    override init(componentDescription: AudioComponentDescription, options: AudioComponentInstantiationOptions = []) throws {
        guard let audioFormat = AVAudioFormat(standardFormatWithSampleRate: 44100.0, channels: 2) else {
            throw MinimoogAudioUnitError.invalidAudioFormat
        }

        instrument = .init(audioFormat: audioFormat)
        inputBus = try .init(format: audioFormat)
        outputBus = try .init(format: audioFormat)
        curParameterTree = try .load(from: "ParametersDescription.plist")

        try super.init(componentDescription: componentDescription, options: options)

        maximumFramesToRender = 512
        currentPreset = AUAudioUnitPreset(with: factoryPresetsManager.defaultPreset())
        setParameterTreeObservers()
    }

    fileprivate var instrument: MinimoogInstrument
    fileprivate var curParameterTree: AUParameterTree
    fileprivate var factoryPresetsManager = FactoryPresetsManager()

    fileprivate var inputBus: AUAudioUnitBus
    fileprivate var outputBus: AUAudioUnitBus

    fileprivate lazy var curInputBusses: AUAudioUnitBusArray = {
        return .init(audioUnit: self, busType: .input, busses: [inputBus])
    }()

    fileprivate lazy var curOutputBusses: AUAudioUnitBusArray = {

        return .init(audioUnit: self, busType: .output, busses: [outputBus])
    }()

    // Positive - factory, negative - user
    fileprivate var curPresetIndex = 0
    fileprivate var curPresetName = ""
}

extension MinimoogAudioUnit {
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
        return self.instrument.internalRenderBlock()
    }

    override public func allocateRenderResources() throws {
        try super.allocateRenderResources()
        guard self.instrument.allocateRenderResources(musicalContext: self.musicalContextBlock,
                                                      outputEventBlock: self.midiOutputEventBlock,
                                                      transportStateBlock: self.transportStateBlock,
                                                      maxFrames: self.maximumFramesToRender)
        else { throw MinimoogAudioUnitError.renderResourcesAllocationFailure }
    }

    override public func deallocateRenderResources() {
        super.deallocateRenderResources()
        self.instrument.deallocateRenderResources()
    }
}

extension MinimoogAudioUnit {
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

extension MinimoogAudioUnit {
    fileprivate func setParameterTreeObservers() {
        curParameterTree.implementorValueObserver = { [weak self] param, value in
            self?.instrument.setParameter(param.address, value: value)
        }

        curParameterTree.implementorValueProvider = { [weak self] param in
            return self?.instrument.getParameter(param.address) ?? AUValue(0)
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
