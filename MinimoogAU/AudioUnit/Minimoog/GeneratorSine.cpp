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

#include "GeneratorSine.hpp"
#include <math.h>

GeneratorSine::GeneratorSine() {
    
}

GeneratorSine::~GeneratorSine() {
    
}

void GeneratorSine::render(float *outL, float *outR) {
    m_phase += 2. * M_PI * m_frequency / m_sampleRate;
    
    if (m_phase > 2. * M_PI) m_phase -= 2. * M_PI;
    
    float osc1Smp = m_amplitude * sin(m_phase);
    
    *outL = osc1Smp;
    *outR = osc1Smp;
}
