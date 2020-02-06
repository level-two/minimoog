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

public final class AUKnobDefaultViewModel {
    private weak var delegate: AUKnobViewModelDelegate?

    init(tiedTo parameter: AUParameter) {
        self.parameter = parameter
        setParameterObserver()
    }

    private var isValueLocked: Bool = false
    private var value: Double = 0

    private var parameter: AUParameter
    private var observerToken: AUParameterObserverToken?
}

extension AUKnobDefaultViewModel: AUKnobViewModel {
    func set(delegate: AUKnobViewModelDelegate?) {
        self.delegate = delegate
    }

    func lockValue() {
        isValueLocked = true
    }

    func unlockValue() {
        isValueLocked = false
    }

    func changeValue(by delta: Double) {
        value = (value + delta).clamped(in: 0...1)
        delegate?.update(for: value)
    }
}

fileprivate extension AUKnobDefaultViewModel {

    func setParameterObserver() {
        observerToken = parameter.observeNormalizedValue() { [weak self] value in
            DispatchQueue.main.async { [weak self] in
                guard self?.isValueLocked == false else { return }
                self?.value = value
                self?.delegate?.update(for: value)
            }
        }
    }

    func removeParameterObserver() {
        guard let observerToken = observerToken else { return }
        parameter.removeParameterObserver(observerToken)
        observerToken = nil
    }
}

//    public var value: CGFloat {
//        get {
//            switch steps {
//            case 0: return curValue
//            case 1: return 0.5
//            default: return (curValue * CGFloat(steps-1)).rounded() / CGFloat(steps-1)
//            }
//        }
//        set {
//            guard !isValueLockedByUI else { return }
//            setValue(newValue, animated: true)
//        }
//    }
//
//    private var curValue: CGFloat = 0
//    private var curAngle: CGFloat = 0
//
//        setValue(newValue.clamped(in: 0...1))
//
//        sendActions(for: .valueChanged)
//    func setValue(_ newValue: CGFloat, animated: Bool = false) {
//        curValue = newValue
//
//        let prevAngle = curAngle
//        curAngle = minAngle + value * (maxAngle - minAngle)
//        knobView?.rotate(by: curAngle - prevAngle, animated: animated)
//    }
