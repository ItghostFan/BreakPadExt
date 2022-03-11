//
//  BreakPadExt.m
//  BreakPadExt
//
//  Created by ItghostFan on 2022/3/10.
//

#import "BreakPadExt.h"

#include "Breakpad.h"
#import "protected_memory_allocator.h"

#include "BreakPadExt.hpp"

#pragma mark - Breakpad

extern ProtectedMemoryAllocator *gMasterAllocator;
extern ProtectedMemoryAllocator *gKeyValueAllocator;
extern ProtectedMemoryAllocator *gBreakpadAllocator;

extern pthread_mutex_t gDictionaryMutex;

BreakpadRef BreakPadExtCreate(NSDictionary *parameters) {
  try {
    // This is confusing.  Our two main allocators for breakpad memory are:
    //    - gKeyValueAllocator for the key/value memory
    //    - gBreakpadAllocator for the Breakpad, ExceptionHandler, and other
    //      breakpad allocations which are accessed at exception handling time.
    //
    // But in order to avoid these two allocators themselves from being smashed,
    // we'll protect them as well by allocating them with gMasterAllocator.
    //
    // gMasterAllocator itself will NOT be protected, but this doesn't matter,
    // since once it does its allocations and locks the memory, smashes to
    // itself don't affect anything we care about.
    gMasterAllocator =
        new ProtectedMemoryAllocator(sizeof(ProtectedMemoryAllocator) * 2);

    gKeyValueAllocator =
        new (gMasterAllocator->Allocate(sizeof(ProtectedMemoryAllocator)))
            ProtectedMemoryAllocator(sizeof(SimpleStringDictionary));

    // Create a mutex for use in accessing the SimpleStringDictionary
    int mutexResult = pthread_mutex_init(&gDictionaryMutex, NULL);
    if (mutexResult == 0) {

      // With the current compiler, gBreakpadAllocator is allocating 1444 bytes.
      // Let's round up to the nearest page size.
      //
      int breakpad_pool_size = 4096;

      /*
       sizeof(Breakpad)
       + sizeof(google_breakpad::ExceptionHandler)
       + sizeof( STUFF ALLOCATED INSIDE ExceptionHandler )
       */

      gBreakpadAllocator =
          new (gMasterAllocator->Allocate(sizeof(ProtectedMemoryAllocator)))
              ProtectedMemoryAllocator(breakpad_pool_size);

      // Stack-based autorelease pool for Breakpad::Create() obj-c code.
        // Itghost Do Not Use MRC
//      NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        
        // Itghost Use Custom BreakPadExt
//      Breakpad *breakpad = Breakpad::Create(parameters);
        Breakpad *breakpad = BreakPadExt::Create(parameters);

      if (breakpad) {
        // Make read-only to protect against memory smashers
        gMasterAllocator->Protect();
        gKeyValueAllocator->Protect();
        gBreakpadAllocator->Protect();
        // Can uncomment this line to figure out how much space was actually
        // allocated using this allocator
        //     printf("gBreakpadAllocator allocated size = %d\n",
        //         gBreakpadAllocator->GetAllocatedSize() );
          // Itghost Do Not Use MRC
//        [pool release];
        return (BreakpadRef)breakpad;
      }
        // Itghost Do Not Use MRC
//      [pool release];
    }
  } catch(...) {    // don't let exceptions leave this C API
      // Itghost Print BreakPadExt。
//    fprintf(stderr, "BreakpadCreate() : error\n");
      fprintf(stderr, "BreakPadExtCreate() : error\n");
  }

  if (gKeyValueAllocator) {
    gKeyValueAllocator->~ProtectedMemoryAllocator();
    gKeyValueAllocator = NULL;
  }

  if (gBreakpadAllocator) {
    gBreakpadAllocator->~ProtectedMemoryAllocator();
    gBreakpadAllocator = NULL;
  }

  delete gMasterAllocator;
  gMasterAllocator = NULL;

  return NULL;
}

void BreakPadExtRelease(BreakpadRef ref) {
  try {
    Breakpad *breakpad = (Breakpad *)ref;

    if (gMasterAllocator) {
      gMasterAllocator->Unprotect();
      gKeyValueAllocator->Unprotect();
      gBreakpadAllocator->Unprotect();
        
        // Itghost Use Custom BreakPadExt
//      breakpad->~Breakpad();
        ((BreakPadExt *)breakpad)->~BreakPadExt();

      // Unfortunately, it's not possible to deallocate this stuff
      // because the exception handling thread is still finishing up
      // asynchronously at this point...  OK, it could be done with
      // locks, etc.  But since BreakpadRelease() should usually only
      // be called right before the process exits, it's not worth
      // deallocating this stuff.
#if 0
      gKeyValueAllocator->~ProtectedMemoryAllocator();
      gBreakpadAllocator->~ProtectedMemoryAllocator();
      delete gMasterAllocator;

      gMasterAllocator = NULL;
      gKeyValueAllocator = NULL;
      gBreakpadAllocator = NULL;
#endif

      pthread_mutex_destroy(&gDictionaryMutex);
    }
  } catch(...) {    // don't let exceptions leave this C API
    fprintf(stderr, "BreakpadRelease() : error\n");
  }
}

#pragma mark - BreakPadExt

//ProtectedMemoryAllocator *gBreakPadExAllocator = NULL;

BreakPadExt::BreakPadExt() {
}

BreakPadExt::~BreakPadExt() {
}

Breakpad* BreakPadExt::Create(NSDictionary *parameters) {
  // Allocate from our special allocation pool
  BreakPadExt *breakpad =
    new (gBreakpadAllocator->Allocate(sizeof(BreakPadExt)))
      BreakPadExt();

  if (!breakpad)
    return NULL;

  if (!breakpad->Initialize(parameters)) {
    // Don't use operator delete() here since we allocated from special pool
    breakpad->~BreakPadExt();
    return NULL;
  }

  return breakpad;
}
