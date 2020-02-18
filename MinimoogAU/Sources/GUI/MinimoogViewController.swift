// -----------------------------------------------------------------------------
//    Copyright (C) 2019 Yauheni Lychkouski.
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

import UIKit
import AudioToolbox
import AVFoundation
import CoreAudioKit
import AudioUnitBase
import AUControls

public class MinimoogViewController: AUViewController {
    @IBOutlet var tabButtons: [UIButton]?
    @IBOutlet var embeddedViews: [UIView]?

    @IBAction func onButton(_ sender: UIButton) {
        guard let index = tabButtons?.firstIndex(of: sender) else { return }
        tabButtons?.enumerated().forEach { idx, btn in btn.isSelected = (idx == index) }
        embeddedViews?.enumerated().forEach { idx, view in view.isHidden = (idx != index) }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
    }

    fileprivate var audioUnit: AUAudioUnit? {
        didSet { commonInit() }
    }
}

extension MinimoogViewController: AUAudioUnitFactory {
    public func createAudioUnit(with componentDescription: AudioComponentDescription) throws -> AUAudioUnit {
        switch componentDescription.componentSubType {
        case 0x6d6f6f67: // 'moog'
            let audioUnit = try AUAudioUnit.create(with: SineGenerator(), componentDescription: componentDescription)
            self.audioUnit = audioUnit
            return audioUnit
        case 0x73706563: // 'spec'
            let audioUnit = try AUAudioUnit.create(with: SineGenerator(), componentDescription: componentDescription)
            self.audioUnit = audioUnit
            return audioUnit
        default:
            throw AUAudioUnitFactoryError.invalidComponentDescription
        }
    }
}

fileprivate extension MinimoogViewController {
    func commonInit() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                self.isViewLoaded,
                let parameterTree = self.audioUnit?.parameterTree
                else { return }

            self.configureEmbeddedViews(with: parameterTree)
            self.tabButtons?.enumerated().forEach { idx, btn in btn.isSelected = (idx == 0) }
            self.embeddedViews?.enumerated().forEach { idx, view in view.isHidden = (idx != 0) }
        }
    }

    func configureEmbeddedViews(with parameterTree: AUParameterTree) {
        embeddedViews?
            .compactMap { $0.subviews.first?.parentViewController as? ParameterTreeConfigurable }
            .forEach { $0.configure(with: parameterTree) }
    }
}
