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
import AVFoundation

public final class OutputModule: AudioUnitModule {
    override var audioOutputConnected: Bool {
        return true
    }

    func render(_ frameCount: AUAudioFrameCount, into buffers: inout [UnsafeMutablePointer<Float32>]) {
        super.render(frameCount)

        // TODO: take into account number of channels
        buffers.forEach {
            $0.initialize(from: self.audioOutput!, count: Int(frameCount))
        }
    }
}
