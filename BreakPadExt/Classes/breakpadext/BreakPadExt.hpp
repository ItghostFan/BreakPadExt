//
//  BreakPadExt.hpp
//  BreakPadExt
//
//  Created by ItghostFan on 2022/3/10.
//

#ifndef BreakPadExt_hpp
#define BreakPadExt_hpp

#include "Breakpad.hpp"

class BreakPadExt : public Breakpad {
public:
    static Breakpad *Create(NSDictionary *parameters);

    BreakPadExt();
    ~BreakPadExt();
};


#endif /* BreakPadExt_hpp */
