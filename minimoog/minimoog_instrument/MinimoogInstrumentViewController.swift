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
    
    // MARK: Outlets
    @IBOutlet weak var osc1RangeSlider     : UISlider!
    @IBOutlet weak var osc1WaveformSlider  : UISlider!
    @IBOutlet weak var osc2RangeSlider     : UISlider!
    @IBOutlet weak var osc2DetuneSlider    : UISlider!
    @IBOutlet weak var osc2WaveformSlider  : UISlider!
    @IBOutlet weak var mixOsc1VolumeSlider : UISlider!
    @IBOutlet weak var mixOsc2VolumeSlider : UISlider!
    @IBOutlet weak var mixNoiseVolumeSlider: UISlider!
    
    @IBOutlet weak var osc1RangeLabel     : UILabel!
    @IBOutlet weak var osc1WaveformLabel  : UILabel!
    @IBOutlet weak var osc2RangeLabel     : UILabel!
    @IBOutlet weak var osc2DetuneLabel    : UILabel!
    @IBOutlet weak var osc2WaveformLabel  : UILabel!
    @IBOutlet weak var mixOsc1VolumeLabel : UILabel!
    @IBOutlet weak var mixOsc2VolumeLabel : UILabel!
    @IBOutlet weak var mixNoiseVolumeLabel: UILabel!
    
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
        let value = roundf(osc1RangeSlider.value)
        osc1RangeSlider.value = value
        guard let parameter = audioUnit?.parameterTree?.parameter(withAddress: ParamAddr.osc1RangeParamAddr.rawValue) else { return }
        if parameter.value != value {
            parameter.setValue(value, originator: parameterObserverToken)
            osc1RangeLabel.text = parameter.valueStrings![Int(value)]
        }
    }
    
    @IBAction func osc1WaveformChanged(_ sender: Any) {
        let value = roundf(osc1WaveformSlider.value)
        osc1WaveformSlider.value = value
        guard let parameter = audioUnit?.parameterTree?.parameter(withAddress: ParamAddr.osc1WaveformParamAddr.rawValue) else { return }
        if parameter.value != value {
            parameter.setValue(value, originator: parameterObserverToken)
            osc1WaveformLabel.text = parameter.valueStrings![Int(value)]
        }
    }
    
    @IBAction func osc2RangeChanged(_ sender: Any) {
        let value = roundf(osc2RangeSlider.value)
        osc2RangeSlider.value = value
        guard let parameter = audioUnit?.parameterTree?.parameter(withAddress: ParamAddr.osc2RangeParamAddr.rawValue) else { return }
        if parameter.value != value {
            parameter.setValue(value, originator: parameterObserverToken)
            osc2RangeLabel.text = parameter.valueStrings![Int(value)]
        }
    }
    
    @IBAction func osc2DetuneChanged(_ sender: Any) {
        guard let parameter = audioUnit?.parameterTree?.parameter(withAddress: ParamAddr.osc2DetuneParamAddr.rawValue) else { return }
        parameter.setValue(osc2DetuneSlider.value, originator: parameterObserverToken)
    }
    
    @IBAction func osc2WaveformChanged(_ sender: Any) {
        let value = roundf(osc2WaveformSlider.value)
        osc2WaveformSlider.value = value
        guard let parameter = audioUnit?.parameterTree?.parameter(withAddress: ParamAddr.osc2WaveformParamAddr.rawValue) else { return }
        if parameter.value != value {
            parameter.setValue(value, originator: parameterObserverToken)
            osc2WaveformLabel.text = parameter.valueStrings![Int(value)]
        }
    }
    
    @IBAction func mixOsc1VolumeChanged(_ sender: Any) {
        guard let parameter = audioUnit?.parameterTree?.parameter(withAddress: ParamAddr.mixOsc1VolumeParamAddr.rawValue) else { return }
        parameter.setValue(mixOsc1VolumeSlider.value, originator: parameterObserverToken)
    }
    
    @IBAction func mixOsc2VolumeChanged(_ sender: Any) {
        guard let parameter = audioUnit?.parameterTree?.parameter(withAddress: ParamAddr.mixOsc2VolumeParamAddr.rawValue) else { return }
        parameter.setValue(mixOsc2VolumeSlider.value, originator: parameterObserverToken)
    }
    
    @IBAction func mixNoiseVolumeChanged(_ sender: Any) {
        guard let parameter = audioUnit?.parameterTree?.parameter(withAddress: ParamAddr.mixNoiseVolumeParamAddr.rawValue) else { return }
        parameter.setValue(mixNoiseVolumeSlider.value, originator: parameterObserverToken)
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
        guard let parameter = audioUnit?.parameterTree?.parameter(withAddress: address) else { return }
        
        switch address {
        case ParamAddr.osc1RangeParamAddr.rawValue:
            osc1RangeLabel.text = parameter.valueStrings![Int(value)]
            osc1RangeSlider.value = value
        case ParamAddr.osc1WaveformParamAddr.rawValue:
            osc1WaveformLabel.text = parameter.valueStrings![Int(value)]
            osc1WaveformSlider.value = value
        case ParamAddr.osc2RangeParamAddr.rawValue:
            osc2RangeLabel.text = parameter.valueStrings![Int(value)]
            osc2RangeSlider.value = value
        case ParamAddr.osc2DetuneParamAddr.rawValue:
            osc2DetuneSlider.value = value
        case ParamAddr.osc2WaveformParamAddr.rawValue:
            osc2WaveformLabel.text = parameter.valueStrings![Int(value)]
            osc2WaveformSlider.value = value
        case ParamAddr.mixOsc1VolumeParamAddr.rawValue:
            mixOsc1VolumeSlider.value = value
        case ParamAddr.mixOsc2VolumeParamAddr.rawValue:
            mixOsc2VolumeSlider.value = value
        case ParamAddr.mixNoiseVolumeParamAddr.rawValue:
            mixNoiseVolumeSlider.value = value
        default:
            print("Unknown address")
        }
    }
}
