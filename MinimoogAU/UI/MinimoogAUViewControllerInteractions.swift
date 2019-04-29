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
import RxSwift
import RxCocoa

extension MinimoogAUViewController {
    func assembleViewInteractions() {
        parameterObserverToken = audioUnit?.parameterTree.token(byAddingParameterObserver: { [weak self] address, value in
            DispatchQueue.main.async { self?.setKnobValue(address, value) }
        })

        self.knobContainerView.forEach { pair in
            let (parameterId, container) = pair

            container.knob
                .rx.controlEvent(.valueChanged)
                .bind { [weak self] in
                    guard let self = self else { return }
                    guard let parameter = self.audioUnit?.parameterTree.parameter(withAddress: parameterId.address) else { return }

                    parameter.setValue(AUValue(container.knob.value), originator: self.parameterObserverToken)
                }.disposed(by: disposeBag)
        }

    }
}
