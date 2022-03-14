//
//  BreakPadExtController.m
//  BreakPadExt
//
//  Created by ItghostFan on 2022/3/9.
//

#import "BreakPadExtController.h"

#import <objc/runtime.h>

#import "BreakpadController.h"
#include "BreakPadExt.hpp"
#include "Breakpad.h"
#import "BreakPadExt.h"

@interface BreakPadExtController ()
@property (strong, nonatomic) BreakpadController *breakPadController;
@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
@implementation BreakPadExtController
#pragma clang pop

- (instancetype)init {
    if (self = [super init]) {
        self.breakPadController = [BreakpadController sharedInstance];
    }
    return self;
}

#pragma mark - BreakpadController IVar Getter & Setter

- (BOOL)started {
    return [[self.breakPadController valueForKey:@"started_"] boolValue];
}

- (void)setStarted:(BOOL)started {
    [self.breakPadController setValue:@(started) forKey:@"started_"];
}

- (BreakpadRef)breakpadRef {
    BreakpadRef breakpadRef = NULL;
    Ivar var = class_getInstanceVariable(self.breakPadController.class, "breakpadRef_");
    breakpadRef = (__bridge BreakpadRef)object_getIvar(self.breakPadController, var);
    return breakpadRef;
}

- (void)setBreakpadRef:(BreakpadRef)breakpadRef {
    Ivar var = class_getInstanceVariable(self.breakPadController.class, "breakpadRef_");
    object_setIvar(self.breakPadController, var, (__bridge id)breakpadRef);
//    return [self.breakPadController setValue:@((NSUInteger)breakPadRef) forKey:@"breakpadRef_"];
}

- (NSMutableDictionary *)configuration {
    return [self.breakPadController valueForKey:@"configuration_"];
}

- (dispatch_queue_t)queue {
    return [self.breakPadController valueForKey:@"queue_"];
}

#pragma mark - BreakpadController

- (void)start:(BOOL)onCurrentThread {
    if (self.started)
        return;
    self.started = YES;
    void(^startBlock)() = ^{
        assert(!self.breakpadRef);
        // Itghost Use BreakPadExt
//        self.breakpadRef = BreakpadCreate(self.configuration);
        self.breakpadRef = BreakPadExtCreate(self.configuration);
        if (self.breakpadRef) {
            BreakpadAddUploadParameter(self.breakpadRef, @"platform", GetPlatform());
        }
    };
    if (onCurrentThread)
        startBlock();
    else
        dispatch_async(self.queue, startBlock);
}

- (void)stop {
    if (!self.started)
        return;
    self.started = NO;
    dispatch_sync(self.queue, ^{
        if (self.breakpadRef) {
            // Itghost Use BreakPadExt
//            BreakpadRelease(self.breakpadRef);
            BreakPadExtRelease(self.breakpadRef);
            self.breakpadRef = NULL;
        }
    });
}

// Returns a NSString describing the current platform.
NSString* GetPlatform() {
  // Name of the system call for getting the platform.
  static const char kHwMachineSysctlName[] = "hw.machine";

  NSString* result = nil;

  size_t size = 0;
  if (sysctlbyname(kHwMachineSysctlName, NULL, &size, NULL, 0) || size == 0)
    return nil;
  google_breakpad::scoped_array<char> machine(new char[size]);
  if (sysctlbyname(kHwMachineSysctlName, machine.get(), &size, NULL, 0) == 0)
    result = [NSString stringWithUTF8String:machine.get()];
  return result;
}

#pragma mark - Breakpad

BOOL IsDebuggerActive(void) {
  BOOL result = NO;
  NSUserDefaults *stdDefaults = [NSUserDefaults standardUserDefaults];

  // We check both defaults and the environment variable here

  BOOL ignoreDebugger = [stdDefaults boolForKey:@IGNORE_DEBUGGER];

  if (!ignoreDebugger) {
    char *ignoreDebuggerStr = getenv(IGNORE_DEBUGGER);
    ignoreDebugger =
        (ignoreDebuggerStr ? strtol(ignoreDebuggerStr, NULL, 10) : 0) != 0;
  }

  if (!ignoreDebugger) {
    pid_t pid = getpid();
    int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_PID, pid};
    int mibSize = sizeof(mib) / sizeof(int);
    size_t actualSize;

    if (sysctl(mib, mibSize, NULL, &actualSize, NULL, 0) == 0) {
      struct kinfo_proc *info = (struct kinfo_proc *)malloc(actualSize);

      if (info) {
        // This comes from looking at the Darwin xnu Kernel
        if (sysctl(mib, mibSize, info, &actualSize, NULL, 0) == 0)
          result = (info->kp_proc.p_flag & P_TRACED) ? YES : NO;

        free(info);
      }
    }
  }

  return result;
}

#pragma mark - Forward Invocation

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    NSMethodSignature *methodSignature = [self.class instanceMethodSignatureForSelector:anInvocation.selector];
    if (methodSignature) {
        [anInvocation invokeWithTarget:self];
    } else {
        [anInvocation invokeWithTarget:self.breakPadController];
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature *methodSignature = [self.class instanceMethodSignatureForSelector:aSelector];
    if (methodSignature) {
        return methodSignature;
    }
    return [self.breakPadController methodSignatureForSelector:aSelector];
}

@end
