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

#ifndef MinimoogInstrument_hpp
#define MinimoogInstrument_hpp

#import <AudioToolbox/AudioToolbox.h>
#import "MinimoogBase.hpp"
#import "GeneratorBase.hpp"

// Define parameter addresses.
enum {
    osc1Range = 0,
    osc1Waveform,
    osc2Range,
    osc2Detune,
    osc2Waveform,
    mixOsc1Volume,
    mixOsc2Volume,
    mixNoiseVolume
};

class Minimoog : public MinimoogBase {
public:
    Minimoog();
    virtual ~Minimoog();
    
    // Overrides
    virtual void    setParameter   (AUParameterAddress address, AUValue value);
    virtual AUValue getParameter   (AUParameterAddress address);
    virtual void    startRamp      (AUParameterAddress address, AUValue value, AUAudioFrameCount duration);
    virtual void    handleMIDIEvent(AUMIDIEvent const& midiEvent);
    virtual bool    doAllocateRenderResources();
    virtual void    doDeallocateRenderResources();
    virtual void    doRender       (float *outL, float *outR);
    virtual void    setSampleRate  (float sr);
    
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
    int m_osc1SelectedGenerator = 0;
    GeneratorBase* m_osc1Generator[6];
    
    // OSC2
    int m_osc2SelectedGenerator = 0;
    GeneratorBase* m_osc2Generator[6];
    
    // NOISE
    float m_noiseAmpl;
    
    // MIX
    float m_mixOsc1AmplMultiplier;
    float m_mixOsc2AmplMultiplier;
    float m_mixNoiseAmplMultiplier;
};

#endif /* MinimoogInstrument_hpp */
