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

#ifndef GenaratorBase_hpp
#define GenaratorBase_hpp

#include <stdio.h>

class GeneratorBase {
public:
    GeneratorBase();
    virtual ~GeneratorBase();
    
    virtual void render(float *outL, float *outR) = 0;
    
    void setFrequency(float frequency) { m_frequency = frequency; }
    void setAmplitude(float amplitude) { m_amplitude = amplitude; }
    void setSampleRate(float sampleRate) { m_sampleRate = sampleRate; }
    
protected:
    float m_frequency = 0;
    float m_amplitude = 0;
    float m_sampleRate = 0;
};



#endif /* GenaratorBase_hpp */
