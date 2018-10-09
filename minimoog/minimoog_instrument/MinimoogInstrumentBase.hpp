//
//  MinimoogInstrumentBase.hpp
//  Minimoog_instrument
//
//  Created by Yauheni Lychkouski on 10/9/18.
//  Copyright © 2018 Yauheni Lychkouski. All rights reserved.
//


#ifndef MinimoogInstrumentBase_h
#define MinimoogInstrumentBase_h

#import <AudioToolbox/AudioToolbox.h>
#import <algorithm>

template <typename T>
T clamp(T input, T low, T high) {
	return std::min(std::max(input, low), high);
}

// Put your DSP code into a subclass of DSPKernel.
class MinimoogInstrumentBase {
public:
    MinimoogInstrumentBase();
    virtual ~MinimoogInstrumentBase();
    
	virtual void  process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) = 0;
	virtual void  startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) = 0;
	virtual void  handleMIDIEvent(AUMIDIEvent const& midiEvent) {}
    virtual void  setParameter(long int address, float value) {}
    virtual float getParameter(long int address) { return 0; }
	
	void processWithEvents(AudioTimeStamp const* timestamp, AUAudioFrameCount frameCount, AURenderEvent const* events);

private:
	void handleOneEvent(AURenderEvent const* event);
	void performAllSimultaneousEvents(AUEventSampleTime now, AURenderEvent const*& event);
};

#endif /* MinimoogInstrumentBase_h */
