//
//  GenaratorBase.hpp
//  MinimoogAU
//
//  Created by Yauheni Lychkouski on 4/29/19.
//  Copyright © 2019 Yauheni Lychkouski. All rights reserved.
//

#ifndef GenaratorBase_hpp
#define GenaratorBase_hpp

#include <stdio.h>

class GeneratorBase {
public:
    GeneratorBase();
    virtual ~GeneratorBase();
    
    virtual void onRender(float *outL, float *outR) = 0;
    
    void setFrequency(float frequency) { m_frequency = frequency; }
    void setAmplitude(float amplitude) { m_amplitude = amplitude; }
    void setSampleRate(float sampleRate) { m_sampleRate = sampleRate; }
    
protected:
    float m_frequency = 0;
    float m_amplitude = 0;
    float m_sampleRate = 0;
    
    float m_currentValueL = 0;
    float m_currentValueR = 0;
    float m_currentPhase = 0;
    float m_currentTime = 0;
};



#endif /* GenaratorBase_hpp */
