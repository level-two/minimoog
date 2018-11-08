//
//  AudioUnitViewController.swift
//  minimoog_instrument
//
//  Created by Yauheni Lychkouski on 10/6/18.
//  Copyright © 2018 Yauheni Lychkouski. All rights reserved.
//

import UIKit
import CoreAudioKit

public class MinimoogInstrumentViewController: AUViewController, AUAudioUnitFactory {
    // MARK: Outlets
    @IBOutlet weak var osc1RangeKnob     : MinimoogInstrumentKnob!
    @IBOutlet weak var osc1WaveformKnob  : MinimoogInstrumentKnob!
    @IBOutlet weak var osc2RangeKnob     : MinimoogInstrumentKnob!
    @IBOutlet weak var osc2DetuneKnob    : MinimoogInstrumentKnob!
    @IBOutlet weak var osc2WaveformKnob  : MinimoogInstrumentKnob!
    @IBOutlet weak var mixOsc1VolumeKnob : MinimoogInstrumentKnob!
    @IBOutlet weak var mixOsc2VolumeKnob : MinimoogInstrumentKnob!
    @IBOutlet weak var mixNoiseVolumeKnob: MinimoogInstrumentKnob!
    
    // MARK: Public variables
    public var audioUnit: AUAudioUnit? {
        didSet {
            DispatchQueue.main.async { [unowned self] in
                guard self.isViewLoaded else { return }
                
                self.connectViewWithAU()
                
                // Assign default values to all controls
                MinimoogInstrumentAudioUnit.ParamAddr.allCases.forEach { addr in
                    guard let parameter = self.audioUnit?.parameterTree?.parameter(withAddress: addr.rawValue) else { return }
                    self.updateUiControl(withAddress: addr, value: parameter.value)
                }
            }
        }
    }
    
    // MARK: Private variables
    var parameterObserverToken  : AUParameterObserverToken?
    
    // MARK: Overrides
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        guard audioUnit != nil else { return }
        // Get the parameter tree and add observers for any parameters that the UI needs to keep in sync with the AudioUnit
        connectViewWithAU()
        
        // Assign default values to all controls
        MinimoogInstrumentAudioUnit.ParamAddr.allCases.forEach { addr in
            guard let parameter = audioUnit?.parameterTree?.parameter(withAddress: addr.rawValue) else { return }
            updateUiControl(withAddress: addr, value: parameter.value)
        }
    }
    
    // MARK: AUAudioUnitFactory protocol implementation
    public func createAudioUnit(with componentDescription: AudioComponentDescription) throws -> AUAudioUnit {
        audioUnit = try MinimoogInstrumentAudioUnit(componentDescription: componentDescription, options: [])
        return audioUnit!
    }
    
    func connectViewWithAU() {
        guard let paramTree = audioUnit?.parameterTree else { return }
        parameterObserverToken = paramTree.token(byAddingParameterObserver: { [weak self] address, value in
            guard
                let strongSelf = self,
                let addr = MinimoogInstrumentAudioUnit.ParamAddr(rawValue:UInt64(value))
            else { return }
            
            DispatchQueue.main.async {
                strongSelf.updateUiControl(withAddress:addr, value:value)
            }
        })
    }
    
    func setParameterValue(withAddress address:MinimoogInstrumentAudioUnit.ParamAddr, value:AUValue) {
        guard let parameter = audioUnit?.parameterTree?.parameter(withAddress:address.rawValue) else { return }
        parameter.setValue(value, originator: parameterObserverToken)
    }
    
    func updateUiControl(withAddress address:MinimoogInstrumentAudioUnit.ParamAddr, value:AUValue) {
        switch address {
        case .osc1RangeParamAddr:
            osc1RangeKnob.value = value
        case .osc1WaveformParamAddr:
            osc1WaveformKnob.value = value
        case .osc2RangeParamAddr:
            osc2RangeKnob.value = value
        case .osc2DetuneParamAddr:
            osc2DetuneKnob.value = value
        case .osc2WaveformParamAddr:
            osc2WaveformKnob.value = value
        case .mixOsc1VolumeParamAddr:
            mixOsc1VolumeKnob.value = value
        case .mixOsc2VolumeParamAddr:
            mixOsc2VolumeKnob.value = value
        case .mixNoiseVolumeParamAddr:
            mixNoiseVolumeKnob.value = value
        }
    }
    
    // MARK: Actions
    @IBAction func osc1RangeChanged(_ sender: Any) {
        setParameterValue(withAddress:.osc1RangeParamAddr, value: osc1RangeKnob.value)
    }
    
    @IBAction func osc1WaveformChanged(_ sender: Any) {
        setParameterValue(withAddress:.osc1WaveformParamAddr, value: osc1WaveformKnob.value)
    }
    
    @IBAction func osc2RangeChanged(_ sender: Any) {
        setParameterValue(withAddress:.osc2RangeParamAddr, value: osc2RangeKnob.value)
    }
    
    @IBAction func osc2DetuneChanged(_ sender: Any) {
        setParameterValue(withAddress:.osc2DetuneParamAddr, value: osc2DetuneKnob.value)
    }
    
    @IBAction func osc2WaveformChanged(_ sender: Any) {
        setParameterValue(withAddress:.osc2WaveformParamAddr, value: osc2WaveformKnob.value)
    }
    
    @IBAction func mixOsc1VolumeChanged(_ sender: Any) {
        setParameterValue(withAddress:.mixOsc1VolumeParamAddr, value: mixOsc1VolumeKnob.value)
    }
    
    @IBAction func mixOsc2VolumeChanged(_ sender: Any) {
        setParameterValue(withAddress:.mixOsc2VolumeParamAddr, value: mixOsc2VolumeKnob.value)
    }
    
    @IBAction func mixNoiseVolumeChanged(_ sender: Any) {
        setParameterValue(withAddress:.mixNoiseVolumeParamAddr, value: mixNoiseVolumeKnob.value)
    }
}
