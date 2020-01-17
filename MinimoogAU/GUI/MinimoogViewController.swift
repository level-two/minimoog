// -----------------------------------------------------------------------------
//    Copyright (C) 2019 Yauheni Lychkouski.
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

import UIKit
import CoreAudioKit
import UIControls
import AVFoundation

public class MinimoogViewController: AUViewController {
    @IBOutlet var knobs: [UIKnob]!

    override public func viewDidLoad() {
        super.viewDidLoad()
        setKnobsTarget()

        if let parameterTree = audioUnit?.parameterTree {
            configureKnobs(with: parameterTree)
        }
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setParameterObserver()
    }

    override public func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeParameterObserver()
    }

    fileprivate var parameterObserverToken: AUParameterObserverToken?
    fileprivate var audioUnit: AUAudioUnit? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self,
                    self.isViewLoaded,
                    let parameterTree = self.audioUnit?.parameterTree
                    else { return }
                self.configureKnobs(with: parameterTree)
            }
        }
    }
}

extension MinimoogViewController: AUAudioUnitFactory {
    public func createAudioUnit(with componentDescription: AudioComponentDescription) throws -> AUAudioUnit {
        guard let audioFormat = AVAudioFormat(standardFormatWithSampleRate: 44100.0, channels: 2) else {
            throw AudioUnitError.invalidAudioFormat
        }
        let module = SineModule(sampleRate: Float32(audioFormat.sampleRate))
        let instrument = Instrument(audioFormat: audioFormat, module: module)
        self.audioUnit = try AudioUnit(audioFormat: audioFormat,
                                       instrument: instrument,
                                       componentDescription: componentDescription,
                                       options: [])
        return self.audioUnit!
    }
}

fileprivate extension MinimoogViewController {
    func configureKnobs(with parameterTree: AUParameterTree) {
        knobs.forEach { knob in
            let address = AUParameterAddress(knob.parameterAddress)
            guard let parameter = parameterTree.parameter(withAddress: address) else { return }
            knob.title = parameter.identifier
            knob.minValue = CGFloat(parameter.minValue)
            knob.maxValue = CGFloat(parameter.maxValue)
            if let stepsCount = parameter.valueStrings?.count, stepsCount > 0 {
                knob.step = (knob.maxValue - knob.minValue) / CGFloat(stepsCount)
            }
            knob.value = CGFloat(parameter.value)
            knob.updateLabels()
        }
    }

    func setKnobsTarget() {
        self.knobs.forEach { knob in
            knob.addTarget(self, action: #selector(MinimoogViewController.onKnobValueChanged), for: .valueChanged)
        }
    }

    func setKnobValue(_ address: AUParameterAddress, _ value: AUValue) {
        knobs.first { $0.parameterAddress == address }?.value = CGFloat(value)
    }

    @objc func onKnobValueChanged(knob: UIKnob) {
        audioUnit?
            .parameterTree?
            .parameter(withAddress: AUParameterAddress(knob.parameterAddress))?
            .setValue(AUValue(knob.value), originator: self.parameterObserverToken)
    }
}

fileprivate extension MinimoogViewController {
    func setParameterObserver() {
        parameterObserverToken = audioUnit?.parameterTree?.token() { [weak self] address, value in
            DispatchQueue.main.async { [weak self] in
                self?.setKnobValue(address, value)
            }
        }
    }

    func removeParameterObserver() {
        guard let token = parameterObserverToken else { return }
        audioUnit?.parameterTree?.removeParameterObserver(token)
        parameterObserverToken = nil
    }
}
