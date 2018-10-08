//
//  MinimoogInstrument.hpp
//  Minimoog_instrument
//
//  Created by Yauheni Lychkouski on 10/9/18.
//  Copyright © 2018 Yauheni Lychkouski. All rights reserved.
//

#ifndef MinimoogInstrument_hpp
#define MinimoogInstrument_hpp

#include <stdio.h>

class MinimoogInstrument {
public:
    MinimoogInstrument();
    ~MinimoogInstrument();
    
    void  setParameter(long int address, float value);
    float getParameter(long int address);
private:
};

#endif /* MinimoogInstrument_hpp */
