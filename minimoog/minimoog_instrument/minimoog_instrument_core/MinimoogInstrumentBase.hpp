//
//  MinimoogInstrumentBase.hpp
//  Minimoog_instrument
//
//  Created by Yauheni Lychkouski on 10/9/18.
//  Copyright © 2018 Yauheni Lychkouski. All rights reserved.
//

#ifndef MinimoogInstrumentBase_hpp
#define MinimoogInstrumentBase_hpp

#import <AudioToolbox/AudioToolbox.h>
#import <algorithm>

template <typename T>
T clamp(T input, T low, T high) {
	return std::min(std::max(input, low), high);
}

class MinimoogInstrumentBase {
public:
    MinimoogInstrumentBase();
    virtual ~MinimoogInstrumentBase();
    
    // Pure virtual methods
    virtual bool    allocateRenderResources()   = 0;
    virtual void    deallocateRenderResources() = 0;
    virtual void    setParameter   (AUParameterAddress address, AUValue value)                             = 0;
    virtual AUValue getParameter   (AUParameterAddress address)                                            = 0;
	virtual void    startRamp      (AUParameterAddress address, AUValue value, AUAudioFrameCount duration) = 0;
    virtual void    handleMIDIEvent(AUMIDIEvent const& midiEvent)                                          = 0;
    virtual void    doRender       (float *outL, float *outR)                                              = 0;
	
    // Public methods
    void setSampleRate(float sr) { m_sampleRate = sr; };
    
    void render(AudioUnitRenderActionFlags* actionFlags          ,
                const AudioTimeStamp*       timestamp            ,
                AUAudioFrameCount           frameCount           ,
                NSInteger                   outputBusNumber      ,
                AudioBufferList*            outputData           ,
                const AURenderEvent*        realtimeEventListHead,
                AURenderPullInputBlock      pullInputBlock       );
private:
    // Private methods
	void handleOneEvent(AURenderEvent const* event);
	void performAllSimultaneousEvents(AUEventSampleTime now,
                                      AURenderEvent const* &event);
    void renderSegmentFrames(AUAudioFrameCount frameCount        ,
                             AudioBufferList*  outputData        ,
                             AUAudioFrameCount const bufferOffset);
    
    // Protected variables
protected:
    float m_sampleRate;
};

#endif /* MinimoogInstrumentBase_hpp */
