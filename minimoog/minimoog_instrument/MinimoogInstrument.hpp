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
#import <algorithm>
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
    AudioUnitParameterID paramAddr;
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
    
    virtual void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration);
    virtual void handleMIDIEvent(AUMIDIEvent const& midiEvent);
    virtual void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset);
    virtual void setParameter(AUParameterAddress address, AUValue value);
    virtual AUValue getParameter(AUParameterAddress address);

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
    int m_current_note;
    
    // OSC1
    float m_osc1_ampl;
    float m_osc1_freq;
    float m_osc1_freq_multiplier;
    float m_osc1_phase;
    
    // OSC2
    float m_osc2_ampl;
    float m_osc2_freq;
    float m_osc2_freq_multiplier;
    float m_osc2_freq_detune;
    float m_osc2_phase;
    
    // NOISE
    float m_noise_ampl;
    
    // MIX
    float m_mix_osc1_ampl_multiplier;
    float m_mix_osc2_ampl_multiplier;
    float m_mix_noise_ampl_multiplier;
};

#endif /* MinimoogInstrument_hpp */
