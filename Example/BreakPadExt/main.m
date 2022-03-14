//
//  main.m
//  BreakPadExt
//
//  Created by ItghostFan on 2022/3/11.
//

#import <UIKit/UIKit.h>
#import "BPCrashAppDelegate.h"

int main(int argc, char * argv[]) {
    NSString * appDelegateClassName;
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([BPCrashAppDelegate class]);
    }
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
