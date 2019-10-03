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

#ifndef GeneratorSaw_hpp
#define GeneratorSaw_hpp

#include <stdio.h>
#include "GeneratorBase.hpp"

class GeneratorSaw: public GeneratorBase {
public:
    GeneratorSaw();
    GeneratorSaw(float raiseTime);
    virtual ~GeneratorSaw();
    
    virtual void render(float *outL, float *outR);
    void setRaiseTime(float raiseTime) { m_raiseTime = raiseTime;}
    
private:
    float m_relTime = 0;
    float m_raiseTime = 0;
};

#endif /* GeneratorSaw_hpp */
