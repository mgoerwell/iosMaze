//
//  CPlusPlusCounter.cpp
//  COMP8051 Assignment1
//
//  Created by Jason Cheung on 2018-02-13.
//  Copyright © 2018 Jason Cheung. All rights reserved.
//

#include "CPlusPlusCounter.h"

int CPlusPlusCounter::GetValue()
{
    return value;
}

void CPlusPlusCounter::SetValue(int newValue)
{
    value = newValue;
}

void CPlusPlusCounter::Increment()
{
    value++;
}
