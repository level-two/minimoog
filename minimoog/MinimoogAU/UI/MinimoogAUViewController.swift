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
    public let onKnob = PublishSubject<(parameterId: MinimoogAU., value: AUValue)>()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        assemble()
        setupLayout()
        bindEvents()
    }
    
    
    func setKnobValue(withAddress address: MinimoogAU.ParamAddr, value:AUValue) {
        return
        switch address {
        case .osc1Range:
            osc1RangeKnob.value = value
        case .osc1Waveform:
            osc1WaveformKnob.value = value
        case .osc2Range:
            osc2RangeKnob.value = value
        case .osc2Detune:
            osc2DetuneKnob.value = value
        case .osc2Waveform:
            osc2WaveformKnob.value = value
        case .mixOsc1Volume:
            mixOsc1VolumeKnob.value = value
        case .mixOsc2Volume:
            mixOsc2VolumeKnob.value = value
        case .mixNoiseVolume:
            mixNoiseVolumeKnob.value = value
        }
    }
    
    private let osc1Group          = UIView()
    private let osc1RangeKnob      = UIKnob()
    private let osc1WaveformKnob   = UIKnob()
    
    private let osc2Group          = UIView()
    private let osc2RangeKnob      = UIKnob()
    private let osc2DetuneKnob     = UIKnob()
    private let osc2WaveformKnob   = UIKnob()
    
    private let mixGroup           = UIView()
    private let mixOsc1VolumeKnob  = UIKnob()
    private let mixOsc2VolumeKnob  = UIKnob()
    private let mixNoiseVolumeKnob = UIKnob()
    
    private let disposeBag = DisposeBag()
}

extension MinimoogAUViewController {
    func bindEvents() {
        // TODO: User ParameterID instead of Int
        osc1RangeKnob.rx.value.map { (parameterId: .osc1Range, value: $0) }.bind(to: onKnob).disposed(by: disposeBag)
        /*
        osc1RangeKnob      = UIKnob()
        osc1WaveformKnob   = UIKnob()
        osc2RangeKnob      = UIKnob()
        osc2DetuneKnob     = UIKnob()
        osc2WaveformKnob   = UIKnob()
        mixOsc1VolumeKnob  = UIKnob()
        mixOsc2VolumeKnob  = UIKnob()
        mixNoiseVolumeKnob = UIKnob()
         */
    }
    
    
}
