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

class MinimoogAUKnobContainerView: UIView {
    public func assembleView() {
        addSubviews(
            knob,
            title
        )
    }

    public func setupLayout() {
        knob.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(50)
        }

        title.snp.makeConstraints { make in
            make.centerX.width.equalToSuperview()
            make.bottom.equalTo(self.knob.snp.top)
        }
    }

    public func styleView() {
        backgroundColor = .clear
        title.textAlignment = .center
    }

    public func setTitle(_ text: String) {
        title.text = text
    }

    public func setKnobProperties(minValue: CGFloat, maxValue: CGFloat, stepSize: CGFloat, minAngle: CGFloat = -150, maxAngle: CGFloat = 150) {
        knob.minValue = minValue
        knob.maxValue = maxValue
        knob.stepSize = stepSize
        knob.minAngle = minAngle
        knob.maxAngle = maxAngle
    }

    public func setKnobValue(_ value: CGFloat) {
        knob.value = value
    }

    let knob = UIKnob()
    let title = UILabel()
}
