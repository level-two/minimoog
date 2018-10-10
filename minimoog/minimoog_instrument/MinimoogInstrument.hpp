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
    mixNoiseVolumeParamAddr,
    lastParamAddr
};

typedef struct {
    AUParameterAddress paramAddr;
    const char *identifier;
    const char *name;
    AUValue min;
    AUValue max;
    AUValue initVal;
    AudioUnitParameterUnit unit;
    const char *commaSeparatedIndexedNames;
} ParameterDef;

const ParameterDef paramDef[] = {
    {osc1RangeParamAddr     , "osc1Range"     , "Oscillator 1 Range"       ,  0,  5,  0, kAudioUnitParameterUnit_Indexed, "LO,32',16',8',4',2'" },
    {osc1WaveformParamAddr  , "osc1Waveform"  , "Oscillator 1 Waveform"    ,  0,  5,  0, kAudioUnitParameterUnit_Indexed, "Triangle,Ramp,Sawtooth,Square,Pulse1,Pulse2" },
    {osc2RangeParamAddr     , "osc2Range"     , "Oscillator 2 Range"       ,  0,  5,  0, kAudioUnitParameterUnit_Indexed, "LO,32',16',8',4',2'" },
    {osc2DetuneParamAddr    , "osc2Detune"    , "Oscillator 2 Detune"      , -8,  8,  0, kAudioUnitParameterUnit_Cents  , "" },
    {osc2WaveformParamAddr  , "osc2Waveform"  , "Oscillator 2 Waveform"    ,  0,  5,  0, kAudioUnitParameterUnit_Indexed,  "Triangle,Ramp,Sawtooth,Square,Pulse1,Pulse2" },
    {mixOsc1VolumeParamAddr , "mixOsc1Volume" , "Mixer Oscillator 1 Volume",  0, 10, 10, kAudioUnitParameterUnit_CustomUnit, "" },
    {mixOsc2VolumeParamAddr , "mixOsc2Volume" , "Mixer Oscillator 2 Volume",  0, 10,  0, kAudioUnitParameterUnit_CustomUnit, "" },
    {mixNoiseVolumeParamAddr, "mixNoiseVolume", "Mixer Noise Volume"       ,  0, 10,  0, kAudioUnitParameterUnit_CustomUnit, "" },
    {lastParamAddr}
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
