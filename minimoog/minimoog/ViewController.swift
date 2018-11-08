//
//  ViewController.swift
//  minimoog
//
//  Created by Yauheni Lychkouski on 10/5/18.
//  Copyright © 2018 Yauheni Lychkouski. All rights reserved.
//

import UIKit
import AudioToolbox

class ViewController: UIViewController {

    @IBOutlet weak var minimoogInstrumentAUContainerView: UIView!
    @IBOutlet weak var playButton: UIButton!
    
    var playEngine: SimplePlayEngine!
    var minimoogInstrumentViewController: MinimoogInstrumentViewController!
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the plug-in's custom view.
        embedPlugInView()
        
        // Create an audio file playback engine.
        playEngine = SimplePlayEngine(componentType: kAudioUnitType_MusicDevice)
        
        /*
         Register the AU in-process for development/debugging.
         First, build an AudioComponentDescription matching the one in our
         .appex's Info.plist.
         */
        // MARK: AudioComponentDescription Important!
        // Ensure that you update the AudioComponentDescription for your AudioUnit type, manufacturer and creator type.
        var componentDescription = AudioComponentDescription()
        componentDescription.componentType = kAudioUnitType_MusicDevice
        componentDescription.componentSubType = 0x6d6f6f67 /*'moog'*/
        componentDescription.componentManufacturer = 0x594c5943 /*'YLYC'*/
        componentDescription.componentFlags = 0
        componentDescription.componentFlagsMask = 0
        
        /*
         Register our `AUAudioUnit` subclass, `AUv3FilterDemo`, to make it able
         to be instantiated via its component description.
         
         Note that this registration is local to this process.
         */
        AUAudioUnit.registerSubclass(MinimoogInstrumentAudioUnit.self, as: componentDescription, name:"Minimoog emulation demo", version: UInt32.max)
        
        // Instantiate and insert our audio unit effect into the chain.
        playEngine.selectAudioUnitWithComponentDescription(componentDescription) {
            // This is an asynchronous callback when complete. Finish audio unit setup.
            self.connectParametersToControls()
        }
    }
    
    /// Called from `viewDidLoad(_:)` to embed the plug-in's view into the app's view.
    func embedPlugInView() {
        /*
         Locate the app extension's bundle, in the app bundle's PlugIns
         subdirectory. Load its MainInterface storyboard, and obtain the
         `FilterDemoViewController` from that.
         */
        let builtInPlugInsURL = Bundle.main.builtInPlugInsURL!
        let pluginURL = builtInPlugInsURL.appendingPathComponent("minimoog_instrument.appex")
        let appExtensionBundle = Bundle(url: pluginURL)
        
        let storyboard = UIStoryboard(name: "MainInterface", bundle: appExtensionBundle)
        minimoogInstrumentViewController = storyboard.instantiateInitialViewController() as? MinimoogInstrumentViewController
        
        // Present the view controller's view.
        if let view = minimoogInstrumentViewController.view {
            addChild(minimoogInstrumentViewController)
            view.frame = minimoogInstrumentAUContainerView.bounds
            
            minimoogInstrumentAUContainerView.addSubview(view)
            minimoogInstrumentViewController.didMove(toParent: self)
        }
    }
    
    func connectParametersToControls() {
        minimoogInstrumentViewController.audioUnit = playEngine.testAudioUnit
    }
    
    /// Handles Play/Stop button touches.
    @IBAction func togglePlay(_ sender: AnyObject?) {
        let isPlaying = playEngine.togglePlay()
        let titleText = isPlaying ? "Stop" : "Play"
        playButton.setTitle(titleText, for: .normal)
    }
}

