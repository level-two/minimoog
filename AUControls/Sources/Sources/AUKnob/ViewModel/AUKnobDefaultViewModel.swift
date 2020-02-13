// -----------------------------------------------------------------------------
//    Copyright (C) 2020 Yauheni Lychkouski.
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

import AudioToolbox

final class AUKnobDefaultViewModel {
    init(tiedTo parameter: AUParameter) {
        self.parameter = parameter
        value = parameter.value
        setParameterObserver()
    }

    deinit {
        removeParameterObserver()
    }

    private var isLockedByUi: Bool = false
    private var value: AUValue {
        didSet { delegate?.update() }
    }
    private var parameter: AUParameter
    private var observerToken: AUParameterObserverToken?
    private weak var delegate: AUKnobViewModelDelegate?
}

extension AUKnobDefaultViewModel: AUKnobViewModel {
    var controlValue: Double {
        let min = parameter.minValue
        let max = parameter.maxValue

        if parameter.unit == .indexed {
            return Double(value.rounded() / max)
        } else {
            return Double((value - min) / (max - min))
        }
    }

    func set(delegate: AUKnobViewModelDelegate?) {
        self.delegate = delegate
    }

    func userInteractionStarted() {
        isLockedByUi = true
    }

    func userInteractionEnded() {
        isLockedByUi = false
    }

    func userChangedControl(by controlDelta: Double) {
        let min = parameter.minValue
        let max = parameter.maxValue
        let fullRange = max - min
        let delta = fullRange * AUValue(controlDelta)
        value = (value + delta).clamped(in: min...max)
    }
}

fileprivate extension AUKnobDefaultViewModel {
    func setParameterObserver() {
        observerToken = parameter.token(byAddingParameterObserver: { [weak self] _, nweValue in
            DispatchQueue.main.async { [weak self] in
                guard let self = self, self.isLockedByUi == false else { return }
                self.value = nweValue
            }
        })
    }

    func removeParameterObserver() {
        guard let observerToken = observerToken else { return }
        parameter.removeParameterObserver(observerToken)
        self.observerToken = nil
    }
}
