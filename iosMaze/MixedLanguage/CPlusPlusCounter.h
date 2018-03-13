//
//  CPlusPlusCounter.hpp
//  COMP8051 Assignment1
//
//  Created by Jason Cheung on 2018-02-13.
//  Copyright © 2018 Jason Cheung. All rights reserved.
//

#ifndef MixedLanguage_CPlusPlusCounter
#define MixedLanguage_CPlusPlusCounter

class CPlusPlusCounter
{
public:
    CPlusPlusCounter() { value = 0; };
    ~CPlusPlusCounter() {};
    
    int GetValue();
    void SetValue(int newValue);
    void Increment();
private:
    int value;
};

#endif

