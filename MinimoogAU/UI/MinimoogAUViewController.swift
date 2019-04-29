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

    var audioUnit: MinimoogAU! {
        didSet {
            guard isViewLoaded else { return }
            assembleViewInteractions()
        }
    }

    public func createAudioUnit(with componentDescription: AudioComponentDescription) throws -> AUAudioUnit {
        self.audioUnit = try MinimoogAU(componentDescription: componentDescription, options: [])
        return self.audioUnit!
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        // View
        assembleView()
        setupLayout()
        styleView()

        // Presenter
        setupKnobContainers()

        // Interactions
        guard audioUnit != nil else { return }
        assembleViewInteractions()
    }

    let topStack = UIStackView()
    let osc1Stack = UIStackView()
    let osc2Stack = UIStackView()
    let mixStack = UIStackView()
    var knobContainerView = [ParameterId: MinimoogAUKnobContainerView]()

    let onKnob = PublishSubject<(ParameterId, AUValue)>()
    let disposeBag = DisposeBag()
}
