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
import Foundation
import AudioToolbox
import UIKit
import CoreAudioKit

class ViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var playButton: UIButton!

    var playEngine: SimplePlayEngine!

    override func viewDidLoad() {
        super.viewDidLoad()

        playEngine = SimplePlayEngine(componentType: kAudioUnitType_MusicDevice)

        var componentDescription = AudioComponentDescription()
        componentDescription.componentType = kAudioUnitType_MusicDevice
        componentDescription.componentSubType = 0x6d6f6f67 /*'moog'*/
        componentDescription.componentManufacturer = 0x594c5943 /*'YLYC'*/
        componentDescription.componentFlags = 0
        componentDescription.componentFlagsMask = 0

        playEngine.selectAudioUnitWithComponentDescription(componentDescription) { [weak self] in
            guard let self = self else { return }
            guard let audioUnit = self.playEngine.testAudioUnit else { return }

            audioUnit.requestViewController { viewController in
                guard let viewController = viewController else { return }

                self.addChild(viewController)
                self.containerView.addSubview(viewController.view)
                viewController.view.frame = self.containerView.bounds
                viewController.didMove(toParent: self)
            }
        }
    }

    @IBAction func togglePlay(_ sender: AnyObject?) {
        let isPlaying = playEngine.togglePlay()
        let titleText = isPlaying ? "Stop" : "Play"
        playButton.setTitle(titleText, for: .normal)
    }
}
