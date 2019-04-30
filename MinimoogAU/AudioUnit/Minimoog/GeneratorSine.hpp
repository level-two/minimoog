//
//  GeneratorSine.hpp
//  MinimoogAU
//
//  Created by Yauheni Lychkouski on 4/29/19.
//  Copyright © 2019 Yauheni Lychkouski. All rights reserved.
//

#ifndef GeneratorSine_hpp
#define GeneratorSine_hpp

#include <stdio.h>
#include "GeneratorBase.hpp"

class GeneratorSine: GeneratorBase {
public:
    GeneratorSine();
    virtual ~GeneratorSine();
    
    virtual void onRender(float *outL, float *outR);
    
private:
};

#endif /* GeneratorSine_hpp */
