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
        osc1RangeSlider.value = round(osc1RangeSlider.value)
        setParameter(withAddress: ParamAddr.osc1RangeParamAddr.rawValue, value: osc1RangeSlider.value)
    }
    
    @IBAction func osc1WaveformChanged(_ sender: Any) {
        osc1WaveformSlider.value = round(osc1WaveformSlider.value)
        setParameter(withAddress: ParamAddr.osc1WaveformParamAddr.rawValue, value: osc1WaveformSlider.value)
    }
    
    @IBAction func osc2RangeChanged(_ sender: Any) {
        osc2RangeSlider.value = round(osc2RangeSlider.value)
        setParameter(withAddress: ParamAddr.osc2RangeParamAddr.rawValue, value: osc2RangeSlider.value)
    }
    
    @IBAction func osc2DetuneChanged(_ sender: Any) {
        setParameter(withAddress: ParamAddr.osc2DetuneParamAddr.rawValue, value: osc2DetuneSlider.value)
    }
    
    @IBAction func osc2WaveformChanged(_ sender: Any) {
        osc2WaveformSlider.value = round(osc2WaveformSlider.value)
        setParameter(withAddress: ParamAddr.osc2WaveformParamAddr.rawValue, value: osc2WaveformSlider.value)
    }
    
    @IBAction func mixOsc1VolumeChanged(_ sender: Any) {
        setParameter(withAddress: ParamAddr.mixOsc1VolumeParamAddr.rawValue, value: mixOsc1VolumeSlider.value)
    }
    
    @IBAction func mixOsc2VolumeChanged(_ sender: Any) {
        setParameter(withAddress: ParamAddr.mixOsc2VolumeParamAddr.rawValue, value: mixOsc2VolumeSlider.value)
    }
    
    @IBAction func mixNoiseVolumeChanged(_ sender: Any) {
        setParameter(withAddress: ParamAddr.mixNoiseVolumeParamAddr.rawValue, value: mixNoiseVolumeSlider.value)
    }
    
    // MARK: Private variables
    var parameterObserverToken  : AUParameterObserverToken?
    
    // MARK: Private methods
    func setParameter(withAddress address:AUParameterAddress, value:AUValue) {
        guard let paramTree = audioUnit?.parameterTree else { return }
        paramTree.parameter(withAddress: address)?.value = value
    }
    
    func connectViewWithAU() {
        guard let paramTree = audioUnit?.parameterTree else { return }
        parameterObserverToken = paramTree.token(byAddingParameterObserver: { [weak self, weak paramTree] address, value in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                switch address {
                case ParamAddr.osc1RangeParamAddr.rawValue:
                    strongSelf.osc1RangeLabel.text = paramTree?.parameter(withAddress: address)?.valueStrings![Int(value)]
                    strongSelf.osc1RangeSlider.value = value
                case ParamAddr.osc1WaveformParamAddr.rawValue:
                    strongSelf.osc1WaveformLabel.text = paramTree?.parameter(withAddress: address)?.valueStrings![Int(value)]
                    strongSelf.osc1WaveformSlider.value = value
                case ParamAddr.osc2RangeParamAddr.rawValue:
                    strongSelf.osc2RangeLabel.text = paramTree?.parameter(withAddress: address)?.valueStrings![Int(value)]
                    strongSelf.osc2RangeSlider.value = value
                case ParamAddr.osc2DetuneParamAddr.rawValue:
                    strongSelf.osc2DetuneSlider.value = value
                case ParamAddr.osc2WaveformParamAddr.rawValue:
                    strongSelf.osc2WaveformLabel.text = paramTree?.parameter(withAddress: address)?.valueStrings![Int(value)]
                    strongSelf.osc2WaveformSlider.value = value
                case ParamAddr.mixOsc1VolumeParamAddr.rawValue:
                    strongSelf.mixOsc1VolumeSlider.value = value
                case ParamAddr.mixOsc2VolumeParamAddr.rawValue:
                    strongSelf.mixOsc2VolumeSlider.value = value
                case ParamAddr.mixNoiseVolumeParamAddr.rawValue:
                    strongSelf.mixNoiseVolumeSlider.value = value
                default:
                    print("Unknown parameter address");
                }
            }
        })
    }
}
