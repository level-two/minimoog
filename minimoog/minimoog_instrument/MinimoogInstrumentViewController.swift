//
//  AudioUnitViewController.swift
//  minimoog_instrument
//
//  Created by Yauheni Lychkouski on 10/6/18.
//  Copyright © 2018 Yauheni Lychkouski. All rights reserved.
//

import UIKit
import CoreAudioKit
import AudioToolbox

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
            /*
             We may be on a dispatch worker queue processing an XPC request at
             this time, and quite possibly the main queue is busy creating the
             view. To be thread-safe, dispatch onto the main queue.
             
             It's also possible that we are already on the main queue, so to
             protect against deadlock in that case, dispatch asynchronously.
             */
            DispatchQueue.main.async {
                if self.isViewLoaded {
                    self.connectViewWithAU()
                }
            }
        }
    }
    
    // MARK: Overrides
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        guard audioUnit != nil else { return }
        // Get the parameter tree and add observers for any parameters that the UI needs to keep in sync with the AudioUnit
        connectViewWithAU()
    }
    
    // MARK: AUAudioUnitFactory protocol implementation
    public func createAudioUnit(with componentDescription: AudioComponentDescription) throws -> AUAudioUnit {
        audioUnit = try MinimoogInstrumentAudioUnit(componentDescription: componentDescription, options: [])
        return audioUnit!
    }
    
    // MARK: Actions
    @IBAction func osc1RangeChanged(_ sender: Any) {
        guard let parameter = audioUnit?.parameterTree?.parameter(withAddress: MinimoogInstrumentAudioUnit.ParamAddr.osc1RangeParamAddr.rawValue) else { return }
        parameter.setValue(osc1RangeKnob.value, originator: parameterObserverToken)
    }
    
    @IBAction func osc1WaveformChanged(_ sender: Any) {
        guard let parameter = audioUnit?.parameterTree?.parameter(withAddress: MinimoogInstrumentAudioUnit.ParamAddr.osc1WaveformParamAddr.rawValue) else { return }
        parameter.setValue(osc1WaveformKnob.value, originator: parameterObserverToken)
    }
    
    @IBAction func osc2RangeChanged(_ sender: Any) {
        guard let parameter = audioUnit?.parameterTree?.parameter(withAddress: MinimoogInstrumentAudioUnit.ParamAddr.osc2RangeParamAddr.rawValue) else { return }
        parameter.setValue(osc2RangeKnob.value, originator: parameterObserverToken)
    }
    
    @IBAction func osc2DetuneChanged(_ sender: Any) {
        guard let parameter = audioUnit?.parameterTree?.parameter(withAddress: MinimoogInstrumentAudioUnit.ParamAddr.osc2DetuneParamAddr.rawValue) else { return }
        parameter.setValue(osc2DetuneKnob.value, originator: parameterObserverToken)
    }
    
    @IBAction func osc2WaveformChanged(_ sender: Any) {
        guard let parameter = audioUnit?.parameterTree?.parameter(withAddress: MinimoogInstrumentAudioUnit.ParamAddr.osc2WaveformParamAddr.rawValue) else { return }
        parameter.setValue(osc2WaveformKnob.value, originator: parameterObserverToken)
    }
    
    @IBAction func mixOsc1VolumeChanged(_ sender: Any) {
        guard let parameter = audioUnit?.parameterTree?.parameter(withAddress: MinimoogInstrumentAudioUnit.ParamAddr.mixOsc1VolumeParamAddr.rawValue) else { return }
        parameter.setValue(mixOsc1VolumeKnob.value, originator: parameterObserverToken)
    }
    
    @IBAction func mixOsc2VolumeChanged(_ sender: Any) {
        guard let parameter = audioUnit?.parameterTree?.parameter(withAddress: MinimoogInstrumentAudioUnit.ParamAddr.mixOsc2VolumeParamAddr.rawValue) else { return }
        parameter.setValue(mixOsc2VolumeKnob.value, originator: parameterObserverToken)
    }
    
    @IBAction func mixNoiseVolumeChanged(_ sender: Any) {
        guard let parameter = audioUnit?.parameterTree?.parameter(withAddress: MinimoogInstrumentAudioUnit.ParamAddr.mixNoiseVolumeParamAddr.rawValue) else { return }
        parameter.setValue(mixNoiseVolumeKnob.value, originator: parameterObserverToken)
    }
    
    // MARK: Private variables
    var parameterObserverToken  : AUParameterObserverToken?
    
    func connectViewWithAU() {
        guard let paramTree = audioUnit?.parameterTree else { return }
        parameterObserverToken = paramTree.token(byAddingParameterObserver: { [unowned self] address, value in
            DispatchQueue.main.async {
                self.updateUI(withAddress:address, value:value)
            }
        })
    }
    
    func updateUI(withAddress address:AUParameterAddress, value:AUValue) {
        let addr = MinimoogInstrumentAudioUnit.ParamAddr(rawValue: UInt64(value))
        switch addr {
        case .osc1RangeParamAddr?:
            osc1RangeKnob.value = value
        case .osc1WaveformParamAddr?:
            osc1WaveformKnob.value = value
        case .osc2RangeParamAddr?:
            osc2RangeKnob.value = value
        case .osc2DetuneParamAddr?:
            osc2DetuneKnob.value = value
        case .osc2WaveformParamAddr?:
            osc2WaveformKnob.value = value
        case .mixOsc1VolumeParamAddr?:
            mixOsc1VolumeKnob.value = value
        case .mixOsc2VolumeParamAddr?:
            mixOsc2VolumeKnob.value = value
        case .mixNoiseVolumeParamAddr?:
            mixNoiseVolumeKnob.value = value
        default:
            print("Unknown address")
        }
    }
}
