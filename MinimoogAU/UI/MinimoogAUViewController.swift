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
import CoreAudioKit
import UIKit
import RxSwift
import RxCocoa

public class MinimoogAUViewController: AUViewController, AUAudioUnitFactory {

    public func createAudioUnit(with componentDescription: AudioComponentDescription) throws -> AUAudioUnit {
        self.audioUnit = try MinimoogAU(componentDescription: componentDescription, options: [])
        return self.audioUnit!
    }

    let topView = UIStackView()
    let osc1Group = UIStackView()
    let osc2Group = UIStackView()
    let mixGroup = UIStackView()
    var knobs = [ParameterId: UIKnob]()
    let onKnob = PublishSubject<(ParameterId, AUValue)>()

    var audioUnit: MinimoogAU?

    let disposeBag = DisposeBag()
    var parameterObserverToken: AUParameterObserverToken?
}
