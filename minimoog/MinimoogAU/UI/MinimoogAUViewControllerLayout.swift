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
    private func assemble() {
        osc1Group.addSubviews(
            osc1RangeKnob,
            osc1WaveformKnob
        )
        
        osc2Group.addSubviews(
            osc2RangeKnob,
            osc2DetuneKnob,
            osc2WaveformKnob
        )
        
        mixGroup.addSubviews(
            mixOsc1VolumeKnob,
            mixOsc2VolumeKnob,
            mixNoiseVolumeKnob
        )
        
        addSubviews(
            osc1Group,
            osc2Group,
            mixGroup
        )
    }
    
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
        osc1RangeKnob.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.centerY.equalTo(superview)
        }
        
        osc1WaveformKnob.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.centerY.equalTo(superview)
        }
        
        self.osc1Group.grids.horizontal(subviews: [osc1RangeKnob, osc1WaveformKnob])
        
        // OSC2 Group
        osc2RangeKnob.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 50, height: 50))
            make.top.equalTo(self.snp.topMargin)
            make.left.equalTo(self.snp.leftMargin)
        }
        
        osc2DetuneKnob.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 50, height: 50))
            make.top.equalTo(self.snp.topMargin)
            make.left.equalTo(self.snp.leftMargin)
        }
        
        osc2WaveformKnob.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 50, height: 50))
            make.top.equalTo(self.snp.topMargin)
            make.left.equalTo(self.snp.leftMargin)
        }
        
        self.osc2Group.grids.horizontal(subviews: [osc2RangeKnob, osc2DetuneKnob, osc2WaveformKnob])
        
        // MIX Group
        mixOsc1VolumeKnob.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 50, height: 50))
            make.top.equalTo(self.snp.topMargin)
            make.left.equalTo(self.snp.leftMargin)
        }
        
        mixOsc2VolumeKnob.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 50, height: 50))
            make.top.equalTo(self.snp.topMargin)
            make.left.equalTo(self.snp.leftMargin)
        }
        
        mixNoiseVolumeKnob.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 50, height: 50))
            make.top.equalTo(self.snp.topMargin)
            make.left.equalTo(self.snp.leftMargin)
        }
        
        self.mixGroup.grids.horizontal(subviews: [mixOsc1VolumeKnob, mixOsc2VolumeKnob, mixNoiseVolumeKnob])
    }
}

