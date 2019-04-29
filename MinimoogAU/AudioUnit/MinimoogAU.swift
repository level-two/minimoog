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

enum MinimoogAUError: Error {
    case invalidAudioFormat
    case renderResourcesAllocationFailure
}

class MinimoogAU: AUAudioUnit {
    override init(componentDescription: AudioComponentDescription, options: AudioComponentInstantiationOptions = []) throws {
        minimoogInstrumentWrapper = MinimoogObjcWrapper()
        factoryPresetsManager = MinimoogAUFactoryPresetsManager()
        curPresetIndex = 0
        curPresetName = ""

        try super.init(componentDescription: componentDescription, options: options)

        initParameterTree()
        setupParameterObservers()

        guard let defaultFormat = AVAudioFormat(standardFormatWithSampleRate: 44100.0, channels: 2) else {
            throw MinimoogAUError.invalidAudioFormat
        }

        //audioStreamBasicDescription = *defaultFormat.streamDescription
        let inputBus = try AUAudioUnitBus(format: defaultFormat)
        let outputBus = try AUAudioUnitBus(format: defaultFormat)
        inputBusses = AUAudioUnitBusArray(audioUnit: self, busType: .input, busses: [inputBus])
        outputBusses = AUAudioUnitBusArray(audioUnit: self, busType: .output, busses: [outputBus])
        minimoogInstrumentWrapper.setSampleRate(defaultFormat.sampleRate)
        maximumFramesToRender = 512

        currentPreset = AUAudioUnitPreset(with: factoryPresetsManager.defaultPreset())
    }

    func initParameterTree() {
        let parameters = AUDescription.parameters.map(AUParameterTree.createParameter)
        parameterTree = AUParameterTree.createTree(withChildren: parameters)
    }

    func setupParameterObservers() {
        parameterTree.implementorValueObserver = { [weak self] param, value in
            self?.minimoogInstrumentWrapper.setParameter(param.address, value: value)
        }

        parameterTree.implementorValueProvider = { [weak self] param in
            return self?.minimoogInstrumentWrapper.getParameter(param.address) ?? AUValue(0)
        }

        parameterTree.implementorStringFromValueCallback = { param, valuePtr in
            let value = (valuePtr == nil ? param.value : valuePtr!.pointee)

            if param.unit == .indexed {
                return param.valueStrings![Int(value)]
            } else {
                return String(format: ".2", value)
            }
        }
    }

    var minimoogInstrumentWrapper: MinimoogObjcWrapper
    var curParameterTree: AUParameterTree!
    var curInputBusses: AUAudioUnitBusArray!
    var curOutputBusses: AUAudioUnitBusArray!
    var factoryPresetsManager: MinimoogAUFactoryPresetsManager

    var curPresetIndex: Int // Positive - factory, negative - user
    var curPresetName: String
}

extension MinimoogAU {
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
        return factoryPresetsManager.allPresets().compactMap { AUAudioUnitPreset(with: $0) }
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
        return self.minimoogInstrumentWrapper.internalRenderBlock()
    }

    override public func allocateRenderResources() throws {
        try super.allocateRenderResources()
        guard self.minimoogInstrumentWrapper.allocateRenderResources(musicalContext: self.musicalContextBlock,
                                                                   outputEventBlock: self.midiOutputEventBlock,
                                                                transportStateBlock: self.transportStateBlock,
                                                                          maxFrames: self.maximumFramesToRender)
        else { throw MinimoogAUError.renderResourcesAllocationFailure }
    }

    override public func deallocateRenderResources() {
        super.deallocateRenderResources()
        self.minimoogInstrumentWrapper.deallocateRenderResources()
    }
}
