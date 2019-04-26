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

import Foundation
import UIKit
import SnapKit

extension MinimoogAUViewController {
    func assembleView() {
        ParameterId.allCases.forEach {
            knobs[$0] = UIKnob()
        }

        osc1Group.addArrangedSubviews(
            knobs[.osc1Range]!,
            knobs[.osc1Waveform]!
        )

        osc2Group.addArrangedSubviews(
            knobs[.osc2Range]!,
            knobs[.osc2Detune]!,
            knobs[.osc2Waveform]!
        )

        mixGroup.addArrangedSubviews(
            knobs[.mixOsc1Volume]!,
            knobs[.mixOsc2Volume]!,
            knobs[.mixNoiseVolume]!
        )

        topView.addArrangedSubviews(
            osc1Group,
            osc2Group,
            mixGroup
        )

        view.addSubviews(
            topView
        )
    }

    func setupLayout() {
        topView.axis = .horizontal
        topView.alignment = .fill
        topView.distribution = .fillEqually

        osc1Group.axis = .vertical
        osc1Group.alignment = .center
        osc1Group.distribution = .equalSpacing

        osc2Group.axis = .vertical
        osc2Group.alignment = .center
        osc2Group.distribution = .equalSpacing

        mixGroup.axis = .vertical
        mixGroup.alignment = .center
        mixGroup.distribution = .equalSpacing

        knobs.forEach { pair in
            let (_, knob) = pair
            knob.snp.makeConstraints { make in
                make.width.height.equalTo(50)
            }
        }

        topView.snp.makeConstraints { make in
            make.center.size.equalToSuperview()
        }
    }
}
