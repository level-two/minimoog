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

import Foundation
import UIKit
import CoreAudioKit
import UIControls

public class MinimoogAUViewController: AUViewController {
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupKnobs()
        setKnobsTarget()
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setParameterObserver()
    }

    override public func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeParameterObserver()
    }

    @IBOutlet var knobs = [UIKnob]()

    fileprivate var audioUnit: MinimoogAU?
    fileprivate var parameterObserverToken: AUParameterObserverToken?
}

extension MinimoogAUViewController: AUAudioUnitFactory {
    public func createAudioUnit(with componentDescription: AudioComponentDescription) throws -> AUAudioUnit {
        self.audioUnit = try MinimoogAU(componentDescription: componentDescription, options: [])
        return self.audioUnit!
    }
}

extension MinimoogAUViewController {
    func setupKnobs() {
        knobs.forEach { knob in
            guard let desc = AUDescription.parameters.first(where: { $0.id.rawValue == knob.parameterId }) else { return }
            knob.title = desc.shortName
            knob.minValue = CGFloat(desc.min)
            knob.maxValue = CGFloat(desc.max)
            knob.step = CGFloat(desc.step)
            knob.value = CGFloat(desc.initValue)
        }

        ParameterId.allCases.forEach { parameterId in
            guard let parameter = self.audioUnit?.parameterTree.parameter(withAddress: parameterId.address) else { return }
            setKnobValue(parameterId.address, parameter.value)
        }
    }

    func setKnobsTarget() {
        self.knobs.forEach { knob in
            knob.addTarget(self, action: #selector(MinimoogAUViewController.onKnobValueChanged), for: .valueChanged)
        }
    }

    func setKnobValue(_ address: AUParameterAddress, _ value: AUValue) {
        knobs.first { $0.parameterId == address }?.value = CGFloat(value)
    }

    @objc func onKnobValueChanged(knob: UIKnob) {
        audioUnit?
            .parameterTree
            .parameter(withAddress: AUParameterAddress(knob.parameterId))?
            .setValue(AUValue(knob.value), originator: self.parameterObserverToken)
    }
}

extension MinimoogAUViewController {
    func setParameterObserver() {
        parameterObserverToken = audioUnit?.parameterTree.token() { [weak self] address, value in
            DispatchQueue.main.async { [weak self] in
                self?.setKnobValue(address, value)
            }
        }
    }

    func removeParameterObserver() {
        guard let token = parameterObserverToken else { return }
        audioUnit?.parameterTree.removeParameterObserver(token)
        parameterObserverToken = nil
    }
}
