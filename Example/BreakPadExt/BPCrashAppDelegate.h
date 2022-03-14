//
//  BPCrashAppDelegate.h
//  BreakPadExt
//
//  Created by ItghostFan on 2022/3/11.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface BPCrashAppDelegate : UIResponder <UIApplicationDelegate>

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

