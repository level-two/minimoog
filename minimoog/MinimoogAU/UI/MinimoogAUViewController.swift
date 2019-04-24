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
import RxSwift
import RxCocoa

public class MinimoogAUViewController: UIViewController {
    public let onKnob = PublishSubject<(MinimoogAU.ParameterId, AUValue)>()

    override public func viewDidLoad() {
        super.viewDidLoad()

        assembleView()
        setupLayout()
        bindEvents()
    }

    public func setKnobValue(withAddress paramId: MinimoogAU.ParameterId, value: AUValue) {
        knobs[paramId]!.value = value
    }

    internal let osc1Group = UIView()
    internal let osc2Group = UIView()
    internal let mixGroup = UIView()

    fileprivate var knobs = [MinimoogAU.ParameterId: UIKnob]()
    fileprivate let disposeBag = DisposeBag()
}

extension MinimoogAUViewController {
    private func assembleView() {
        MinimoogAU.ParameterId.allCases.forEach {
            knobs[$0] = UIKnob()
        }

        osc1Group.addSubviews(
            knob(.osc1Range),
            knob(.osc1Waveform)
        )

        osc2Group.addSubviews(
            knob(.osc2Range),
            knob(.osc2Detune),
            knob(.osc2Waveform)
        )

        mixGroup.addSubviews(
            knob(.mixOsc1Volume),
            knob(.mixOsc2Volume),
            knob(.mixNoiseVolume)
        )

        self.view.addSubviews(
            osc1Group,
            osc2Group,
            mixGroup
        )
    }

    func bindEvents() {
        knobs.forEach { pair in
            let (paramId, knob) = pair
            knob.onValue.map { (paramId, $0) }.bind(to: onKnob).disposed(by: disposeBag)
        }
    }

    func knob(_ paramId: MinimoogAU.ParameterId) -> UIKnob {
        return knobs[paramId]!
    }
}
