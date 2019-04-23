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

#import "Minimoog.hpp"


static inline double noteToHz(int noteNumber)
{
    return 440. * exp2((noteNumber - 69.)/12.);
}

static inline double detunedNoteToHz(int noteNumber, float cents)
{
    return 440. * exp2((noteNumber + cents/8. - 69.)/12.);
}


Minimoog::Minimoog() {
    srand48(time(0));
}

Minimoog::~Minimoog() {
    
}


bool Minimoog::doAllocateRenderResources() {
    return true;
}

void Minimoog::doDeallocateRenderResources() {
    
}

void Minimoog::setParameter(AUParameterAddress address, AUValue value) {
    switch (address) {
        case osc1Range:
            m_osc1Range = value;
            updateOsc1State();
            break;
        case osc1Waveform:
            m_osc1Waveform = value;
            break;
        case osc2Range:
            m_osc2Range = value;
            updateOsc2State();
            break;
        case osc2Detune:
            m_osc2Detune = value;
            updateOsc2State();
            break;
        case osc2Waveform:
            m_osc2Waveform = value;
            break;
        case mixOsc1Volume:
            m_mixOsc1Volume = value;
            m_mixOsc1AmplMultiplier = value / 10.;
            break;
        case mixOsc2Volume:
            m_mixOsc2Volume = value;
            m_mixOsc2AmplMultiplier = value / 10.;
            break;
        case mixNoiseVolume:
            m_mixNoiseVolume = value;
            m_mixNoiseAmplMultiplier = value / 10.;
            break;
    }
}


AUValue Minimoog::getParameter(AUParameterAddress address) {
    AUValue val = 0;
    switch (address) {
        case osc1Range:
            val = m_osc1Range;
            break;
        case osc1Waveform:
            val = m_osc1Waveform;
            break;
        case osc2Range:
            val = m_osc2Range;
            break;
        case osc2Detune:
            val = m_osc2Detune;
            break;
        case osc2Waveform:
            val = m_osc2Waveform;
            break;
        case mixOsc1Volume:
            val = m_mixOsc1Volume;
            break;
        case mixOsc2Volume:
            val = m_mixOsc2Volume;
            break;
        case mixNoiseVolume:
            val = m_mixNoiseVolume;
            break;
    }
    return val;
}


void Minimoog::startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) {
    setParameter(address, value);
}


void Minimoog::handleMIDIEvent(AUMIDIEvent const& midiEvent)
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
            m_osc1Ampl  = 0;
            m_osc2Ampl  = 0;
            m_noiseAmpl = 0;
            break;
        }
        case 0x90 : { // note on
            uint8_t note = midiEvent.data[1];
            m_currentNote = note;
            uint8_t vel  = midiEvent.data[2];
            m_osc1Ampl  = vel / 127.;
            m_osc2Ampl  = vel / 127.;
            m_noiseAmpl = vel / 127.;
            updateOsc1State();
            updateOsc2State();
            break;
        }
        case 0xb0 : { // control change
            uint8_t cc_num = midiEvent.data[1];
            if (cc_num == 0x7b) { // all notes off
                m_osc1Ampl  = 0;
                m_osc2Ampl  = 0;
                m_noiseAmpl = 0;
            }
            break;
        }
    }
}


void Minimoog::updateOsc1State() {
    m_osc1Freq = noteToHz(m_currentNote);
    m_osc1FreqMultiplier = (m_osc1Range == 0) ? 1./128. : exp2f(m_osc1Range - 2.);
}


void Minimoog::updateOsc2State() {
    m_osc2Freq = detunedNoteToHz(m_currentNote, m_osc2Detune);
    m_osc2FreqMultiplier = (m_osc2Range == 0) ? 1./128. : exp2f(m_osc2Range - 2.);
}


void Minimoog::doRender(float *outL, float *outR) {
    // OSC1
    m_osc1Phase += 2.*M_PI * m_osc1Freq * m_osc1FreqMultiplier / m_sampleRate;
    if (m_osc1Phase > 2.*M_PI) m_osc1Phase -= 2.*M_PI;
    float osc1Smp = m_osc1Ampl * sin(m_osc1Phase);
    
    // OSC2
    m_osc2Phase += 2.*M_PI * m_osc2Freq * m_osc2FreqMultiplier / m_sampleRate;
    if (m_osc2Phase > 2.*M_PI) m_osc2Phase -= 2.*M_PI;
    float osc2Smp = m_osc2Ampl * sin(m_osc2Phase);
    
    // NOISE
    float noiseSmp = (float)drand48() * 2. - 1.;
    // MIX
    
    float mixSmp =
        osc1Smp  * m_mixOsc1AmplMultiplier +
        osc2Smp  * m_mixOsc2AmplMultiplier +
        noiseSmp * m_mixNoiseAmplMultiplier;
    
    *outL = mixSmp;
    *outR = mixSmp;
}
