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
            knobContainerView[$0] = MinimoogAUKnobContainerView()
            knobContainerView[$0]!.assembleView()
        }

        osc1Stack.addArrangedSubviews(
            knobContainerView[.osc1Range]!,
            knobContainerView[.osc1Waveform]!
        )

        osc2Stack.addArrangedSubviews(
            knobContainerView[.osc2Range]!,
            knobContainerView[.osc2Detune]!,
            knobContainerView[.osc2Waveform]!
        )

        mixStack.addArrangedSubviews(
            knobContainerView[.mixOsc1Volume]!,
            knobContainerView[.mixOsc2Volume]!,
            knobContainerView[.mixNoiseVolume]!
        )

        topStack.addArrangedSubviews(
            osc1Stack,
            osc2Stack,
            mixStack
        )

        view.addSubviews(
            topStack
        )
    }

    func setupLayout() {
        ParameterId.allCases.forEach {
            knobContainerView[$0]!.setupLayout()
        }

        topStack.snp.makeConstraints { make in
            make.center.size.equalToSuperview()
        }

        topStack.axis = .horizontal
        topStack.alignment = .fill
        topStack.distribution = .fillEqually

        osc1Stack.axis = .vertical
        osc1Stack.alignment = .fill
        osc1Stack.distribution = .fillEqually

        osc2Stack.axis = .vertical
        osc2Stack.alignment = .fill
        osc2Stack.distribution = .fillEqually

        mixStack.axis = .vertical
        mixStack.alignment = .fill
        mixStack.distribution = .fillEqually
    }

    func styleView() {
        [topStack, osc1Stack, osc2Stack, mixStack].forEach {
            $0.spacing = 10
        }

        ParameterId.allCases.forEach {
            knobContainerView[$0]!.styleView()
        }
    }
}
