//
//  BreakPadExt.h
//  BreakPadExt
//
//  Created by ItghostFan on 2022/3/9.
//

#ifndef BreakPadExt_h
#define BreakPadExt_h

//#import "BreakpadController.h"
#import "Breakpad.h"
//#import "ios_exception_minidump_generator.h"

#pragma mark - Breakpad

// Returns a new BreakpadRef object on success, NULL otherwise.
BreakpadRef BreakPadExtCreate(NSDictionary *parameters);

// Uninstall and release the data associated with |ref|.
void BreakPadExtRelease(BreakpadRef ref);

#endif /* BreakPadExt_h */
