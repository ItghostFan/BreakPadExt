//
//  BPCrashAppDelegate.m
//  BreakPadExt
//
//  Created by ItghostFan on 2022/3/11.
//

#import "BPCrashAppDelegate.h"

#define BREAK_PAD_EXT_IMPORTED __has_include("BreakPadExtController.h")

#if BREAK_PAD_EXT_IMPORTED

#define BREAK_PAD_EXT_FRAME_IMPORTED __has_include("BreakPadExtDylib.h")

#if BREAK_PAD_EXT_FRAME_IMPORTED
#import "BreakPadExtDylib.h"
#endif  // #if BREAK_PAD_EXT_FRAME_IMPORTED

#define USE_GOOGLE_BREAKPAD 1

#if USE_GOOGLE_BREAKPAD
#import "client/ios/BreakpadController.h"
typedef BreakpadController BreakpadCrashController;
#else
#import "BreakPadExtController.h"
typedef BreakPadExtController BreakpadCrashController;
#endif  // #if !USE_GOOGLE_BREAKPAD

#endif  // #if BREAK_PAD_EXT_IMPORTED

@interface BPCrashAppDelegate ()

#if BREAK_PAD_EXT_IMPORTED
@property (strong, nonatomic) BreakpadCrashController *crashController;
#endif

@end

@implementation BPCrashAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
#if BREAK_PAD_EXT_IMPORTED
    
#if BREAK_PAD_EXT_FRAME_IMPORTED
    NSLog(@"%f", BreakPadExtDylibVersionNumber);
#endif  // #if BREAK_PAD_EXT_FRAME_IMPORTED
    
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
#if USE_GOOGLE_BREAKPAD
    self.crashController = BreakpadController.sharedInstance;
#else
    self.crashController = [BreakpadCrashController new];
#endif  // #if USE_GOOGLE_BREAKPAD
    [self.crashController updateConfiguration:
         @{
             @BREAKPAD_VENDOR: @"Test",
             @BREAKPAD_DUMP_DIRECTORY: documentPath,
             @BREAKPAD_URL: @"Could Not Be Empty URL"
         }
    ];
    [self.crashController start:NO];
#endif  // #if BREAK_PAD_EXT_IMPORTED
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
#if BREAK_PAD_EXT_IMPORTED
    [self.crashController stop];
#endif  // #if BREAK_PAD_EXT_IMPORTED
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options API_AVAILABLE(ios(13.0)) {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions API_AVAILABLE(ios(13.0)) {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"BreakPadExt"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                    */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

@end
