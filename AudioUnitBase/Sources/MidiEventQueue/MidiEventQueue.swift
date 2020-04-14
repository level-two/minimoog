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
import AVFoundation
import Midi

public class MidiEventQueue: Identifiable {
    public let eventType: MidiEventType
    public let id = UUID()

    public init(eventType: MidiEventType, queueManager: MidiEventQueueManager) {
        self.eventType = eventType
        self.queueManager = queueManager
        eventFrame = []
        nextEventIndex = -1
    }

    func allocateResources(framesCount: AUAudioFrameCount) {
        eventFrame.reserveCapacity(Int(framesCount))
    }

    func deallocateResources() {
        eventFrame = []
        nextEventIndex = -1
    }

    public func removeFromQueue() {
        queueManager?.remove(eventQueue: self)
    }

    func push(_ event: MidiEvent, at frame: AUAudioFrameCount) {
        eventFrame.append((frame, event))
    }

    func newCycle() {
        nextEventIndex = -1
        eventFrame.removeAll(keepingCapacity: true)
    }

    public func event(at frame: AUAudioFrameCount) -> MidiEvent? {
        guard nextEventIndex >= 0 else { return nil }

        if eventFrame[nextEventIndex].frame != frame { return nil }

        let event = eventFrame[nextEventIndex].event

        nextEventIndex += 1
        if nextEventIndex == eventFrame.count {
            nextEventIndex = -1
        }

        return event
    }

    private weak var queueManager: MidiEventQueueManager?
    private var eventFrame: [(frame: AUAudioFrameCount, event: MidiEvent)]
    private var nextEventIndex: Int
}
