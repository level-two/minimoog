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

#include "GeneratorSaw.hpp"
#include <math.h>

GeneratorSaw::GeneratorSaw() {
    
}

GeneratorSaw::GeneratorSaw(float raiseTime) {
    m_raiseTime = raiseTime;
}

GeneratorSaw::~GeneratorSaw() {
    
}

void GeneratorSaw::render(float *outL, float *outR) {
    m_relTime += m_frequency / m_sampleRate;
    
    if (m_relTime >= 1.0) m_relTime -= 1.0;
    
    float sample = 0.0;
    
    if (m_relTime < m_raiseTime) {
        sample = m_amplitude * (-1 + 2 * m_relTime/m_raiseTime);
    } else {
        sample = m_amplitude * (1 - 2 * (m_relTime - m_raiseTime)/(1 - m_raiseTime));
    }
    
    *outL = sample;
    *outR = sample;
}
