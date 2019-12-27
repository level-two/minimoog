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

#ifndef GeneratorSquare_hpp
#define GeneratorSquare_hpp

#include <stdio.h>
#include "GeneratorBase.hpp"

class GeneratorSquare: public GeneratorBase {
public:
    GeneratorSquare();
    GeneratorSquare(float dutyCycle);
    virtual ~GeneratorSquare();
    
    virtual void render(float *outL, float *outR);
    void setDutyCycle(float dutyCycle) { m_dutyCycle = dutyCycle; }
    
private:
    float m_dutyCycle = 0.5;
    float m_relTime = 0;
};

#endif /* GeneratorSquare_hpp */
