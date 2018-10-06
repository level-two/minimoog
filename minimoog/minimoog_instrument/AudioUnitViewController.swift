//
//  AudioUnitViewController.swift
//  minimoog_instrument
//
//  Created by Yauheni Lychkouski on 10/6/18.
//  Copyright © 2018 Yauheni Lychkouski. All rights reserved.
//

import UIKit
import CoreAudioKit

public class AudioUnitViewController: AUViewController, AUAudioUnitFactory {
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
        audioUnit = try minimoog_instrumentAudioUnit(componentDescription: componentDescription, options: [])
        return audioUnit!
    }
    
    // MARK: Actions
    @IBAction func osc1RangeChanged(_ sender: Any) {
        osc1RangeSlider.value = round(osc1RangeSlider.value)
        osc1RangeParameter!.value = osc1RangeSlider.value
    }
    
    @IBAction func osc1WaveformChanged(_ sender: Any) {
        osc1WaveformSlider.value = round(osc1WaveformSlider.value)
        osc1WaveformParameter!.value = osc1WaveformSlider.value
    }
    
    @IBAction func osc2RangeChanged(_ sender: Any) {
        osc2RangeSlider.value = round(osc2RangeSlider.value)
        osc2RangeParameter!.value = osc2RangeSlider.value
    }
    
    @IBAction func osc2DetuneChanged(_ sender: Any) {
        osc2DetuneParameter!.value = osc2DetuneSlider.value
    }
    
    @IBAction func osc2WaveformChanged(_ sender: Any) {
        osc2WaveformSlider.value = round(osc2WaveformSlider.value)
        osc2WaveformParameter!.value = osc2WaveformSlider.value
    }
    
    @IBAction func mixOsc1VolumeChanged(_ sender: Any) {
        mixOsc1VolumeParameter!.value = mixOsc1VolumeSlider.value
    }
    
    @IBAction func mixOsc2VolumeChanged(_ sender: Any) {
        mixOsc2VolumeParameter!.value = mixOsc2VolumeSlider.value
    }
    
    @IBAction func mixNoiseVolumeChanged(_ sender: Any) {
        mixNoiseVolumeParameter!.value = mixNoiseVolumeSlider.value
    }
    
    // MARK: Private variables
    var parameterObserverToken  : AUParameterObserverToken?
    var osc1RangeParameter      : AUParameter?
    var osc1WaveformParameter   : AUParameter?
    var osc2RangeParameter      : AUParameter?
    var osc2DetuneParameter     : AUParameter?
    var osc2WaveformParameter   : AUParameter?
    var mixOsc1VolumeParameter  : AUParameter?
    var mixOsc2VolumeParameter  : AUParameter?
    var mixNoiseVolumeParameter : AUParameter?
    
    // MARK: Private methods
    /*
     We can't assume anything about whether the view or the AU is created first.
     This gets called when either is being created and the other has already
     been created.
     */
    func connectViewWithAU() {
        guard let paramTree = audioUnit?.parameterTree else { return }
        
        osc1RangeParameter      = paramTree.value(forKey: "osc1Range"     ) as? AUParameter
        osc1WaveformParameter   = paramTree.value(forKey: "osc1Waveform"  ) as? AUParameter
        osc2RangeParameter      = paramTree.value(forKey: "osc2Range"     ) as? AUParameter
        osc2DetuneParameter     = paramTree.value(forKey: "osc2Detune"    ) as? AUParameter
        osc2WaveformParameter   = paramTree.value(forKey: "osc2Waveform"  ) as? AUParameter
        mixOsc1VolumeParameter  = paramTree.value(forKey: "mixOsc1Volume" ) as? AUParameter
        mixOsc2VolumeParameter  = paramTree.value(forKey: "mixOsc2Volume" ) as? AUParameter
        mixNoiseVolumeParameter = paramTree.value(forKey: "mixNoiseVolume") as? AUParameter
        
        parameterObserverToken = paramTree.token(byAddingParameterObserver: { [weak self] address, value in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                if address == strongSelf.osc1RangeParameter!.address {
                    strongSelf.osc1RangeUpdate()
                }
                else if address == strongSelf.osc1WaveformParameter!.address {
                    strongSelf.osc1WaveformUpdate()
                }
                else if address == strongSelf.osc2RangeParameter!.address {
                    strongSelf.osc2RangeUpdate()
                }
                else if address == strongSelf.osc2DetuneParameter!.address {
                    strongSelf.osc2DetuneUpdate()
                }
                else if address == strongSelf.osc2WaveformParameter!.address {
                    strongSelf.osc2WaveformUpdate()
                }
                else if address == strongSelf.mixOsc1VolumeParameter!.address {
                    strongSelf.mixOsc1VolumeUpdate()
                }
                else if address == strongSelf.mixOsc2VolumeParameter!.address {
                    strongSelf.mixOsc2VolumeUpdate()
                }
                else if address == strongSelf.mixNoiseVolumeParameter!.address {
                    strongSelf.mixNoiseVolumeUpdate()
                }
            }
        })
        
        osc1RangeUpdate()
        osc1WaveformUpdate()
        osc2RangeUpdate()
        osc2DetuneUpdate()
        osc2WaveformUpdate()
        mixOsc1VolumeUpdate()
        mixOsc2VolumeUpdate()
        mixNoiseVolumeUpdate()
    }
    
    func osc1RangeUpdate() {
        osc1RangeLabel.text = osc1RangeParameter!.string(fromValue: nil)
        osc1RangeSlider.value = osc1RangeParameter!.value
    }
    func osc1WaveformUpdate() {
        osc1WaveformLabel.text = osc1WaveformParameter!.string(fromValue: nil)
        osc1WaveformSlider.value = osc1WaveformParameter!.value
    }
    func osc2RangeUpdate() {
        osc2RangeLabel.text = osc2RangeParameter!.string(fromValue: nil)
        osc2RangeSlider.value = osc2RangeParameter!.value
    }
    func osc2DetuneUpdate() {
        osc2DetuneLabel.text = osc2DetuneParameter!.string(fromValue: nil)
        osc2DetuneSlider.value = osc2DetuneParameter!.value
    }
    func osc2WaveformUpdate() {
        osc2WaveformLabel.text = osc2WaveformParameter!.string(fromValue: nil)
        osc2WaveformSlider.value = osc2WaveformParameter!.value
    }
    func mixOsc1VolumeUpdate() {
        mixOsc1VolumeLabel.text = mixOsc1VolumeParameter!.string(fromValue: nil)
        mixOsc1VolumeSlider.value = mixOsc1VolumeParameter!.value
    }
    func mixOsc2VolumeUpdate() {
        mixOsc2VolumeLabel.text = mixOsc2VolumeParameter!.string(fromValue: nil)
        mixOsc2VolumeSlider.value = mixOsc2VolumeParameter!.value
    }
    func mixNoiseVolumeUpdate() {
        mixNoiseVolumeLabel.text = mixNoiseVolumeParameter!.string(fromValue: nil)
        mixNoiseVolumeSlider.value = mixNoiseVolumeParameter!.value
    }
}
