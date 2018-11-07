//
//  MinimoogInstrument.hpp
//  Minimoog_instrument
//
//  Created by Yauheni Lychkouski on 10/9/18.
//  Copyright © 2018 Yauheni Lychkouski. All rights reserved.
//

#ifndef MinimoogInstrument_hpp
#define MinimoogInstrument_hpp

#import <AudioToolbox/AudioToolbox.h>
#import "MinimoogInstrumentBase.hpp"

// Define parameter addresses.
enum {
    osc1RangeParamAddr = 0,
    osc1WaveformParamAddr,
    osc2RangeParamAddr,
    osc2DetuneParamAddr,
    osc2WaveformParamAddr,
    mixOsc1VolumeParamAddr,
    mixOsc2VolumeParamAddr,
    mixNoiseVolumeParamAddr
};

class MinimoogInstrument : public MinimoogInstrumentBase {
public:
    MinimoogInstrument();
    virtual ~MinimoogInstrument();
    
    // Overrides
    virtual void    setParameter   (AUParameterAddress address, AUValue value);
    virtual AUValue getParameter   (AUParameterAddress address);
    virtual void    startRamp      (AUParameterAddress address, AUValue value, AUAudioFrameCount duration);
    virtual void    handleMIDIEvent(AUMIDIEvent const& midiEvent);
    virtual bool    doAllocateRenderResources();
    virtual void    doDeallocateRenderResources();
    virtual void    doRender       (float *outL, float *outR);

private:
    void updateOsc1State();
    void updateOsc2State();
    
    // Parameters
    AUValue m_osc1Range;
    AUValue m_osc1Waveform;
    AUValue m_osc2Range;
    AUValue m_osc2Detune;
    AUValue m_osc2Waveform;
    AUValue m_mixOsc1Volume;
    AUValue m_mixOsc2Volume;
    AUValue m_mixNoiseVolume;
    
    // OSC Common
    int m_currentNote;
    
    // OSC1
    float m_osc1Ampl;
    float m_osc1Freq;
    float m_osc1FreqMultiplier;
    float m_osc1Phase;
    
    // OSC2
    float m_osc2Ampl;
    float m_osc2Freq;
    float m_osc2FreqMultiplier;
    float m_osc2FreqDetune;
    float m_osc2Phase;
    
    // NOISE
    float m_noiseAmpl;
    
    // MIX
    float m_mixOsc1AmplMultiplier;
    float m_mixOsc2AmplMultiplier;
    float m_mixNoiseAmplMultiplier;
};

#endif /* MinimoogInstrument_hpp */
