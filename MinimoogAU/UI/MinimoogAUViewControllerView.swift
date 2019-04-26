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
            knobs[$0]!.backgroundColor = UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1)
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
        osc1Group.alignment = .fill
        osc1Group.distribution = .fillEqually

        osc2Group.axis = .vertical
        osc2Group.alignment = .fill
        osc2Group.distribution = .fillEqually

        mixGroup.axis = .vertical
        mixGroup.alignment = .fill
        mixGroup.distribution = .fillEqually

        knobs.forEach { pair in
            let (_, knob) = pair
            knob.snp.makeConstraints { make in
                make.size.height.equalTo(knob.snp.width)
            }
        }

        topView.snp.makeConstraints { make in
            make.center.equalTo(self.view)
            make.size.equalTo(self.view)
        }
    }
}
