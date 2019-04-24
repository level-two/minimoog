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
import CustomUiKit

public class MinimoogAUViewController: AUViewController, AUAudioUnitFactory {
    public let onKnob = PublishSubject<(MinimoogAU.ParameterId, AUValue)>()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        assembleView()
        setupLayout()
        bindEvents()
    }
    
    public func setKnobValue(withAddress paramId: MinimoogAU.ParameterId, value: AUValue) {
        knob[paramId].value = value
    }
    
    private let osc1Group = UIView()
    private let osc2Group = UIView()
    private let mixGroup = UIView()
    private let knob = [MinimoogAU.ParameterId: UIKnob]()
    
    private let disposeBag = DisposeBag()
}

extension MinimoogAUViewController {
    private func assembleView() {
        MinimoogAU.ParameterId.forEach {
            knob[$0] = UIKnob()
        }
        
        osc1Group.addSubviews(
            knob[.osc1Range],
            knob[.osc1Waveform]
        )
        
        osc2Group.addSubviews(
            knob[.osc2Range],
            knob[.osc2Detune],
            knob[.osc2Waveform]
        )
        
        mixGroup.addSubviews(
            knob[.mixOsc1Volume],
            knob[.mixOsc2Volume],
            knob[.mixNoiseVolume]
        )
        
        addSubviews(
            osc1Group,
            osc2Group,
            mixGroup
        )
    }
    
    func bindEvents() {
        knob.forEach { paramId, knob in
            knob.rx.value.map { (paramId, $0) }.bind(to: onKnob).disposed(by: disposeBag)
        }
    }
}
