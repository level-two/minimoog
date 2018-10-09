//
//  MinimoogInstrumentBase.cpp
//  Minimoog_instrument
//
//  Created by Yauheni Lychkouski on 10/9/18.
//  Copyright © 2018 Yauheni Lychkouski. All rights reserved.
//


#import "MinimoogInstrumentBase.hpp"

void MinimoogInstrumentBase::handleOneEvent(AURenderEvent const *event) {
	switch (event->head.eventType) {
        case AURenderEventParameter: {
            AUParameterEvent const& paramEvent = event->parameter;
            setParameter(paramEvent.parameterAddress, paramEvent.value);
            break;
        }
		case AURenderEventParameterRamp: {
			AUParameterEvent const& paramEvent = event->parameter;
			startRamp(paramEvent.parameterAddress, paramEvent.value, paramEvent.rampDurationSampleFrames);
			break;
		}
		case AURenderEventMIDI:
			handleMIDIEvent(event->MIDI);
			break;
		default:
			break;
	}
}

void MinimoogInstrumentBase::performAllSimultaneousEvents(AUEventSampleTime now, AURenderEvent const *&event) {
	do {
		handleOneEvent(event);
		// Go to next event.
		event = event->head.next;
		// While event is not null and is simultaneous (or late).
	} while (event && event->head.eventSampleTime <= now);
}

/**
	This function handles the event list processing and rendering loop for you.
	Call it inside your internalRenderBlock.
*/
void MinimoogInstrumentBase::processWithEvents(AudioTimeStamp const *timestamp, AUAudioFrameCount frameCount, AURenderEvent const *events) {

	AUEventSampleTime now = AUEventSampleTime(timestamp->mSampleTime);
	AUAudioFrameCount framesRemaining = frameCount;
	AURenderEvent const *event = events;
	
	while (framesRemaining > 0) {
		// If there are no more events, we can process the entire remaining segment and exit.
		if (event == nullptr) {
			AUAudioFrameCount const bufferOffset = frameCount - framesRemaining;
			process(framesRemaining, bufferOffset);
			return;
		}

        // **** start late events late.
		auto timeZero = AUEventSampleTime(0);
		auto headEventTime = event->head.eventSampleTime;
		AUAudioFrameCount const framesThisSegment = AUAudioFrameCount(std::max(timeZero, headEventTime - now));
		
		// Compute everything before the next event.
		if (framesThisSegment > 0) {
			AUAudioFrameCount const bufferOffset = frameCount - framesRemaining;
			process(framesThisSegment, bufferOffset);
							
			// Advance frames.
			framesRemaining -= framesThisSegment;

			// Advance time.
			now += AUEventSampleTime(framesThisSegment);
		}
		
		performAllSimultaneousEvents(now, event);
	}
}

