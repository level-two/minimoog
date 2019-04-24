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
import UIKit
import SnapKit
import CustomUiKit

extension MinimoogAudioUnitViewController {
    private func setupLayout() {
        osc1Group.snp.makeConstraints { make in
            make.top.equalTo(self.snp.topMargin)
            make.left.equalTo(self.snp.leftMargin)
            make.right.equalTo(self.snp.rightMargin)
        }
        
        osc2Group.snp.makeConstraints { make in
            make.top.equalTo(osc1Group.snp.bottomMargin)
            make.left.equalTo(self.snp.leftMargin)
            make.right.equalTo(self.snp.rightMargin)
        }
        
        mixGroup.snp.makeConstraints { make in
            make.top.equalTo(osc2Group.snp.bottomMargin)
            make.left.equalTo(self.snp.leftMargin)
            make.right.equalTo(self.snp.rightMargin)
        }
        
        self.view.grids.vertical(subviews: [osc1Group, osc2Group, mixGroup])
        
        // OSC1 Group
        knob[.osc1Range].snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.centerY.equalTo(superview)
        }
        
        knob[.osc1Waveform].snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.centerY.equalTo(superview)
        }
        
        self.osc1Group.grids.horizontal(subviews: knob[.osc1Range], knob[.osc1Waveform])
        
        // OSC2 Group
        knob[.osc2Range].snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 50, height: 50))
            make.top.equalTo(self.snp.topMargin)
            make.left.equalTo(self.snp.leftMargin)
        }
        
        knob[.osc2Detune].snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 50, height: 50))
            make.top.equalTo(self.snp.topMargin)
            make.left.equalTo(self.snp.leftMargin)
        }
        
        knob[.osc2Waveform].snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 50, height: 50))
            make.top.equalTo(self.snp.topMargin)
            make.left.equalTo(self.snp.leftMargin)
        }
        
        self.osc2Group.grids.horizontal(subviews: knob[.osc2Range], knob[.osc2Detune], knob[.osc2Waveform])
        
        // MIX Group
        knob[.mixOsc1Volume].snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 50, height: 50))
            make.top.equalTo(self.snp.topMargin)
            make.left.equalTo(self.snp.leftMargin)
        }
        
        knob[.mixOsc2Volume].snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 50, height: 50))
            make.top.equalTo(self.snp.topMargin)
            make.left.equalTo(self.snp.leftMargin)
        }
        
        knob[.mixNoiseVolume].snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 50, height: 50))
            make.top.equalTo(self.snp.topMargin)
            make.left.equalTo(self.snp.leftMargin)
        }
        
        self.mixGroup.grids.horizontal(subviews: [mixOsc1Volume, mixOsc2Volume, mixNoiseVolume])
    }
}

