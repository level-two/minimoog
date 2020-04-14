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
import Midi


public class MidiEventQueueManager {
    public init() {
        
    }

    public func makeQueue(for eventType: MidiEventType) -> MidiEventQueue {
        let listener = MidiEventQueue(eventType: eventType, queueManager: self)
        eventQueues.append(listener)
        return listener
    }

    public func remove(eventQueue: MidiEventQueue) {
        eventQueues.removeAll { $0.id == eventQueue.id }
    }

    public func allocateResources(framesCount: AUAudioFrameCount) {
        eventQueues.forEach { $0.allocateResources(framesCount: framesCount) }
    }

    public func deallocateResources() {
        eventQueues.forEach { $0.deallocateResources() }
    }

    public func push(_ event: MidiEvent, at frame: AUAudioFrameCount) {
        eventQueues.filter { $0.eventType == event.type }.forEach { $0.push(event, at: frame) }
    }

    public func newCycle() {
        eventQueues.forEach { $0.newCycle() }
    }

    private var eventQueues = [MidiEventQueue]()
}
