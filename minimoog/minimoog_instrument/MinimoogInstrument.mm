//
//  MinimoogInstrument.cpp
//  Minimoog_instrument
//
//  Created by Yauheni Lychkouski on 10/9/18.
//  Copyright © 2018 Yauheni Lychkouski. All rights reserved.
//

#import "MinimoogInstrument.hpp"


static inline double noteToHz(int noteNumber)
{
    return 440. * exp2((noteNumber - 69)/12.);
}

static inline double detunedNoteToHz(int noteNumber, float cents)
{
    return 440. * exp2((noteNumber + cents/8 - 69)/12.);
}


MinimoogInstrument::MinimoogInstrument() {
    srand48(time(0));
}

MinimoogInstrument::~MinimoogInstrument() {
    
}

void MinimoogInstrument::setParameter(AUParameterAddress address, AUValue value) {
    switch (address) {
        case osc1RangeParamAddr:
            m_osc1Range = value;
            updateOsc1State();
            break;
        case osc1WaveformParamAddr:
            m_osc1Waveform = value;
            break;
        case osc2RangeParamAddr:
            m_osc2Range = value;
            updateOsc2State();
            break;
        case osc2DetuneParamAddr:
            m_osc2Detune = value;
            updateOsc2State();
            break;
        case osc2WaveformParamAddr:
            m_osc2Waveform = value;
            break;
        case mixOsc1VolumeParamAddr:
            m_mixOsc1Volume = value;
            m_mix_osc1_ampl_multiplier = value / 10;
            break;
        case mixOsc2VolumeParamAddr:
            m_mixOsc2Volume = value;
            m_mix_osc2_ampl_multiplier = value / 10;
            break;
        case mixNoiseVolumeParamAddr:
            m_mixNoiseVolume = value;
            m_mix_noise_ampl_multiplier = value / 10;
            break;
        default:
            break;
    }
}

AUValue MinimoogInstrument::getParameter(AUParameterAddress address) {
    AUValue val = 0;
    switch (address) {
        case osc1RangeParamAddr:
            val = m_osc1Range;
        case osc1WaveformParamAddr:
            val = m_osc1Waveform;
        case osc2RangeParamAddr:
            val = m_osc2Range;
        case osc2DetuneParamAddr:
            val = m_osc2Detune;
        case osc2WaveformParamAddr:
            val = m_osc2Waveform;
        case mixOsc1VolumeParamAddr:
            val = m_mixOsc1Volume;
        case mixOsc2VolumeParamAddr:
            val = m_mixOsc2Volume;
        case mixNoiseVolumeParamAddr:
            val = m_mixNoiseVolume;
    }
    return val;
}


void MinimoogInstrument::startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) {
    setParameter(address, value);
}


void MinimoogInstrument::handleMIDIEvent(AUMIDIEvent const& midiEvent)
{
    // Check whether this is channel message and it has correct format
    if (midiEvent.length != 3 ||
       (midiEvent.data[0] & 0x80) == 0 ||
       (midiEvent.data[1] & 0x80) != 0 ||
       (midiEvent.data[2] & 0x80) != 0) return;
    
    uint8_t status  = midiEvent.data[0] & 0xf0;
    uint8_t channel = midiEvent.data[0] & 0x0f; // works in omni mode
    
    switch (status) {
        case 0x80 : { // note off
            uint8_t note = midiEvent.data[1];
            uint8_t vel  = midiEvent.data[2];
            m_osc1_ampl  = 0;
            m_osc2_ampl  = 0;
            m_noise_ampl = 0;
            break;
        }
        case 0x90 : { // note on
            uint8_t note = midiEvent.data[1];
            m_current_note = note;
            uint8_t vel  = midiEvent.data[2];
            m_osc1_ampl  = vel / 127;
            m_osc2_ampl  = vel / 127;
            m_noise_ampl = vel / 127;
            updateOsc1State();
            updateOsc2State();
            break;
        }
        case 0xb0 : { // control change
            uint8_t cc_num = midiEvent.data[1];
            if (cc_num == 0x7b) { // all notes off
                m_osc1_ampl  = 0;
                m_osc2_ampl  = 0;
                m_noise_ampl = 0;
            }
            break;
        }
    }
}

void MinimoogInstrument::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {
    
}


void MinimoogInstrument::updateOsc1State() {
    m_osc1_freq = noteToHz(m_current_note);
    m_osc1_freq_multiplier = (m_osc1Range == 0) ? 1.0/(1<<7) : 1 << ((int)m_osc1Range - 2);
}


void MinimoogInstrument::updateOsc2State() {
    m_osc2_freq = detunedNoteToHz(m_current_note, m_osc2Detune);
    m_osc2_freq_multiplier = (m_osc2Range == 0) ? 1.0/(1<<7) : 1 << ((int)m_osc2Range - 2);
}


void MinimoogInstrument::generateSample() {
    // OSC1
    m_osc1_phase += M_2_PI * m_osc1_freq * m_osc1_freq_multiplier / sample_rate;
    if (m_osc1_phase > M_2_PI) m_osc1_phase -= M_2_PI;
    float osc1_smp = m_osc1_ampl * sin(m_osc1_phase);
    
    // OSC2
    m_osc2_phase += M_2_PI * m_osc2_freq * m_osc2_freq_multiplier / sample_rate;
    if (m_osc2_phase > M_2_PI) m_osc2_phase -= M_2_PI;
    float osc2_smp = m_osc2_ampl * sin(m_osc2_phase);
    
    // NOISE
    float noise_smp = (float)drand48();
    // MIX
    
    float mix_smp =
        osc1_smp  * m_mix_osc1_ampl_multiplier +
        osc2_smp  * m_mix_osc2_ampl_multiplier +
        noise_smp * m_mix_noise_ampl_multiplier;
}
