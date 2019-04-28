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
    override public func viewDidLoad() {
        super.viewDidLoad()
 
        // View
        assembleView()
        setupLayout()
        styleView()
        
        // Presenter
        setupKnobs()
        
        // Interactions
        assembleViewInteractions()
    }

    func assembleViewInteractions() {
//        self.knobContainerView.forEach { pair in
//            let (paramId, knob) = pair
//            knob.onValue.map { (paramId, $0) }.bind(to: onKnob).disposed(by: disposeBag)
//        }
//        connectViewWithAU()
    }

    func connectViewWithAU() {
        guard let parameterTree = audioUnit?.parameterTree else { return }

        ParameterId.allCases.forEach { parameterId in
            guard let parameter = parameterTree.parameter(withAddress: AUDescription.parameter[parameterId]!.address) else { return }
            self.setParameterValue(for: parameterId, value: parameter.value)
            
        }

        // TODO: Use RX
        parameterObserverToken = parameterTree.token(byAddingParameterObserver: { [weak self] address, value in
            DispatchQueue.main.async {
                guard let parameterId = AUDescription.parameters.first(where: { $0.address == address })?.id else { return }
                self?.setParameterValue(for: parameterId, value: value)
            }
        })
    }

    func setParameterValue(for parameterId: ParameterId, value: AUValue) {
        guard let parameter = audioUnit?.parameterTree.parameter(withAddress: parameterId.rawValue) else { return }
        parameter.setValue(value, originator: parameterObserverToken)
    }

}
