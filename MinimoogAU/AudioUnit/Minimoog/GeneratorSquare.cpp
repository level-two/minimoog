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

#include "GeneratorSquare.hpp"
#include <math.h>

GeneratorSquare::GeneratorSquare() {
    
}

GeneratorSquare::GeneratorSquare(float dutyCycle) {
    m_dutyCycle = dutyCycle;
}


GeneratorSquare::~GeneratorSquare() {
    
}

void GeneratorSquare::render(float *outL, float *outR) {
    m_relTime += m_frequency / m_sampleRate;
    
    if (m_relTime >= 1.0) m_relTime -= 1.0;
    
    float sample = m_amplitude * (m_relTime <= m_dutyCycle ? 1 : -1);
    
    *outL = sample;
    *outR = sample;
}
