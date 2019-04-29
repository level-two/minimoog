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

extension MinimoogAUViewController {
    func setKnobValue(_ address: AUParameterAddress, _ value: AUValue) {
        guard let id = ParameterId(rawValue: address) else { return }
        knobContainerView[id]!.setKnobValue(CGFloat(value))
    }

    func setupKnobContainers() {
        AUDescription.parameters.forEach(setupKnobContainer)
    }

    fileprivate func setupKnobContainer(using description: ParameterDescription) {
        guard let containerView = knobContainerView[description.id] else { return }
        containerView.setTitle(description.shortName)
        containerView.setKnobProperties(minValue: CGFloat(description.min), maxValue: CGFloat(description.max), stepSize: CGFloat(description.step))
        containerView.setKnobValue(CGFloat(description.initValue))
    }
}
