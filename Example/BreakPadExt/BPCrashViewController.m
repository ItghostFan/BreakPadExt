//
//  BPCrashViewController.m
//  BreakPadExt
//
//  Created by ItghostFan on 03/09/2022.
//  Copyright (c) 2022 ItghostFan. All rights reserved.
//

#import "BPCrashViewController.h"

#import <CoreData/CoreData.h>
#import <Foundation/NSXPCConnection.h>

#import <ReactiveObjC/ReactiveObjC.h>
#import <Masonry/Masonry.h>

#import "Person+CoreDataClass.h"

#define BP_CRASH_ADD_CRASH_TYPE(crashType, order, remark) \
[self addCrashType:self.text##crashType selector:@selector(raise##crashType) index:order comment:remark];

#define BG_CRASH_DEFINE_RAISE(crashType, order) \
- (void)raise##crashType

#define BG_CRASH_DEFINE_TEXT(crashType) \
- (NSString *)text##crashType

@interface BPCrashViewController ()

@property (weak, nonatomic) IBOutlet UIButton *crashTypeButton;
@property (weak, nonatomic) IBOutlet UIButton *raiseCrashButton;

@property (strong, nonatomic) NSMutableDictionary<__kindof NSString *, __kindof UIAlertAction *> *crashTypeActions;
@property (strong, nonatomic) NSMutableDictionary<__kindof NSString *, __kindof NSString *> *crashActions;

#pragma mark - Core Data Properties

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContextA;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContextB;

#pragma mark - GCD

@property (strong, nonatomic) dispatch_group_t group;

@end

@implementation BPCrashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.crashTypeActions = [NSMutableDictionary new];
    self.crashActions = [NSMutableDictionary new];
    [self makeUI];
    [self makeActions];
    
    BP_CRASH_ADD_CRASH_TYPE(NSGenericException,                 @"1.1",     @"✓");
    BP_CRASH_ADD_CRASH_TYPE(NSRangeException,                   @"1.2",     @"✓");
    BP_CRASH_ADD_CRASH_TYPE(NSInvalidArgumentException,         @"1.3",     @"✓");
    BP_CRASH_ADD_CRASH_TYPE(NSInternalInconsistencyException,   @"1.4",     @"✓");
    BP_CRASH_ADD_CRASH_TYPE(NSMallocException,                  @"1.5",     @"✓");
    BP_CRASH_ADD_CRASH_TYPE(NSObjectInaccessibleException,      @"1.6",     @"✓");
    BP_CRASH_ADD_CRASH_TYPE(NSObjectNotAvailableException,      @"1.7",     @"✓");
    BP_CRASH_ADD_CRASH_TYPE(NSDestinationInvalidException,      @"1.8",     @"✓");
    BP_CRASH_ADD_CRASH_TYPE(NSPortTimeoutException,             @"1.9",     @"✗");
    BP_CRASH_ADD_CRASH_TYPE(NSInvalidSendPortException,         @"1.10",    @"✗");
    BP_CRASH_ADD_CRASH_TYPE(NSInvalidReceivePortException,      @"1.11",    @"✗");
    BP_CRASH_ADD_CRASH_TYPE(NSPortSendException,                @"1.12",    @"✗");
    BP_CRASH_ADD_CRASH_TYPE(NSPortReceiveException,             @"1.13",    @"✗");
    BP_CRASH_ADD_CRASH_TYPE(NSOldStyleException,                @"1.14",    @"✗");
    BP_CRASH_ADD_CRASH_TYPE(NSInconsistentArchiveException,     @"1.15",    @"✗");
    BP_CRASH_ADD_CRASH_TYPE(NSUndefinedKeyException,            @"1.16",    @"✓");
    BP_CRASH_ADD_CRASH_TYPE(NSCharacterConversionException,     @"1.17",    @"✓");
    BP_CRASH_ADD_CRASH_TYPE(NSParseErrorException,              @"1.18",    @"✓");
    
    BP_CRASH_ADD_CRASH_TYPE(EXC_BAD_ACCESS,                     @"2.1",     @"✓");
    BP_CRASH_ADD_CRASH_TYPE(EXC_BAD_INSTRUCTION,                @"2.2",     @"✓");
    BP_CRASH_ADD_CRASH_TYPE(EXC_ARITHMETIC,                     @"2.3",     @"✓");
    BP_CRASH_ADD_CRASH_TYPE(EXC_EMULATION,                      @"2.4",     @"✗");
    BP_CRASH_ADD_CRASH_TYPE(EXC_SOFTWARE,                       @"2.5",     @"✗");
    BP_CRASH_ADD_CRASH_TYPE(EXC_BREAKPOINT,                     @"2.6",     @"✗");
    BP_CRASH_ADD_CRASH_TYPE(EXC_SYSCALL,                        @"2.7",     @"✗");
    BP_CRASH_ADD_CRASH_TYPE(EXC_MACH_SYSCALL,                   @"2.8",     @"✗");
    BP_CRASH_ADD_CRASH_TYPE(EXC_RPC_ALERT,                      @"2.9",     @"✗");
    BP_CRASH_ADD_CRASH_TYPE(EXC_CRASH,                          @"2.10",    @"✗");
    BP_CRASH_ADD_CRASH_TYPE(EXC_RESOURCE,                       @"2.11",    @"✗");
    BP_CRASH_ADD_CRASH_TYPE(EXC_GUARD,                          @"2.12",    @"✗");
    BP_CRASH_ADD_CRASH_TYPE(EXC_CORPSE_NOTIFY,                  @"2.13",    @"✗");
    
    BP_CRASH_ADD_CRASH_TYPE(SIGHUP,                             @"3.1",     @"✗");
    BP_CRASH_ADD_CRASH_TYPE(SIGINT,                             @"3.2",     @"✗");
    BP_CRASH_ADD_CRASH_TYPE(SIGQUIT,                            @"3.3",     @"✗");
    BP_CRASH_ADD_CRASH_TYPE(SIGILL,                             @"3.4",     @"✗");
    BP_CRASH_ADD_CRASH_TYPE(SIGTRAP,                            @"3.5",     @"✗");
    BP_CRASH_ADD_CRASH_TYPE(SIGABRT,                            @"3.6",     @"✗");
    BP_CRASH_ADD_CRASH_TYPE(SIGPOLL,                            @"3.7",     @"✗");
    BP_CRASH_ADD_CRASH_TYPE(SIGIOT,                             @"3.8",     @"✗");
    BP_CRASH_ADD_CRASH_TYPE(SIGEMT,                             @"3.9",     @"✗");
    BP_CRASH_ADD_CRASH_TYPE(SIGFPE,                             @"3.10",    @"✗");
    BP_CRASH_ADD_CRASH_TYPE(SIGKILL,                            @"3.11",    @"✗");
    BP_CRASH_ADD_CRASH_TYPE(SIGBUS,                             @"3.12",    @"✗");
    BP_CRASH_ADD_CRASH_TYPE(SIGSEGV,                            @"3.13",    @"✗");
    BP_CRASH_ADD_CRASH_TYPE(SIGSYS,                             @"3.14",    @"✗");
    BP_CRASH_ADD_CRASH_TYPE(SIGPIPE,                            @"3.15",    @"✗");
    BP_CRASH_ADD_CRASH_TYPE(SIGALRM,                            @"3.16",    @"✗");
    BP_CRASH_ADD_CRASH_TYPE(SIGTERM,                            @"3.17",    @"✗");
    BP_CRASH_ADD_CRASH_TYPE(SIGURG,                             @"3.18",    @"✗");
    BP_CRASH_ADD_CRASH_TYPE(SIGSTOP,                            @"3.19",    @"✗");
    BP_CRASH_ADD_CRASH_TYPE(SIGTSTP,                            @"3.20",    @"✗");
    BP_CRASH_ADD_CRASH_TYPE(SIGCONT,                            @"3.21",    @"✗");
    BP_CRASH_ADD_CRASH_TYPE(SIGCHLD,                            @"3.22",    @"✗");
    BP_CRASH_ADD_CRASH_TYPE(SIGTTIN,                            @"3.23",    @"✗");
    BP_CRASH_ADD_CRASH_TYPE(SIGTTOU,                            @"3.24",    @"✗");
    BP_CRASH_ADD_CRASH_TYPE(SIGIO,                              @"3.25",    @"✗");
    BP_CRASH_ADD_CRASH_TYPE(SIGXCPU,                            @"3.26",    @"✗");
    BP_CRASH_ADD_CRASH_TYPE(SIGXFSZ,                            @"3.27",    @"✗");
    BP_CRASH_ADD_CRASH_TYPE(SIGVTALRM,                          @"3.28",    @"✗");
    BP_CRASH_ADD_CRASH_TYPE(SIGPROF,                            @"3.29",    @"✗");
    BP_CRASH_ADD_CRASH_TYPE(SIGWINCH,                           @"3.30",    @"✗");
    BP_CRASH_ADD_CRASH_TYPE(SIGINFO,                            @"3.31",    @"✗");
    BP_CRASH_ADD_CRASH_TYPE(SIGUSR1,                            @"3.32",    @"✗");
    BP_CRASH_ADD_CRASH_TYPE(SIGUSR2,                            @"3.33",    @"✗");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Make UI

- (void)makeUI {
    [self.crashTypeButton setTitle:self.textNSInvalidArgumentException forState:UIControlStateNormal];
    
    [self makeCrashTypeButton];
    [self makeRaiseCrashButton];
}

- (void)makeCrashTypeButton {
    [self.crashTypeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_centerY).offset(-5.0f);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
}

- (void)makeRaiseCrashButton {
    [self.raiseCrashButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_centerY).offset(5.0f);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
}

#pragma mark - Make Actions

- (void)makeActions {
    [self crashTypeButtonClicked];
    [self raiseCrashButtonClicked];
}

- (void)raiseCrashButtonClicked {
    @weakify(self);
    self.raiseCrashButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        @strongify(self);
        SEL selector = NSSelectorFromString(self.crashActions[self.crashTypeButton.titleLabel.text]);
        NSMethodSignature *methodSignature = [self.class instanceMethodSignatureForSelector:selector];
        if (methodSignature) {
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
            invocation.selector = selector;
            [invocation invokeWithTarget:self];
        }
        return RACSignal.empty;
    }];
}

- (void)crashTypeButtonClicked {
    @weakify(self);
    self.crashTypeButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        @strongify(self);
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:self.textSelectCrashType message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        NSArray<__kindof NSString *> *keys = self.crashTypeActions.allKeys;
        keys = [keys sortedArrayUsingComparator:^NSComparisonResult(NSString * _Nonnull obj1, NSString * _Nonnull obj2) {
            NSArray<__kindof NSString *> *indexs1 = [self.crashTypeActions[obj1].title componentsSeparatedByString:@"."];
            NSArray<__kindof NSString *> *indexs2 = [self.crashTypeActions[obj2].title componentsSeparatedByString:@"."];
            NSComparisonResult firstResult = [@(indexs1[0].integerValue) compare:@(indexs2[0].integerValue)];
            if (firstResult == NSOrderedSame) {
                return [@(indexs1[1].integerValue) compare:@(indexs2[1].integerValue)];
            }
            
            return firstResult;
        }];
        for (NSString *key in keys) {
            [controller addAction:self.crashTypeActions[key]];
        }
        [controller addAction:[UIAlertAction actionWithTitle:self.textCancel style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }]];
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            @strongify(self);
            [self presentViewController:controller animated:YES completion:^{
                [subscriber sendCompleted];
            }];
            return nil;
        }];
    }];
}

#pragma mark - Crash Type

- (void)addCrashType:(NSString *)crashType
            selector:(SEL)selector
               index:(NSString *)index
             comment:(NSString *)comment {
    @weakify(self);
    self.crashTypeActions[crashType] = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"%@ %@", index, crashType] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        @strongify(self);
        [self.crashTypeButton setTitle:crashType forState:UIControlStateNormal];
    }];
    self.crashActions[crashType] = NSStringFromSelector(selector);
}

#pragma mark - NSException 1.0

/// *** Terminating app due to uncaught exception 'NSGenericException', reason: '*** Collection <__NSArrayM: 0x6000025ea5e0> was mutated while being enumerated.'
/// Thread 1: EXC_BAD_INSTRUCTION (code=EXC_I386_INVOP, subcode=0x0)
BG_CRASH_DEFINE_RAISE(NSGenericException, 1.1) {
    NSMutableArray *array = [NSMutableArray arrayWithObjects:@0, @1, @2, @3, nil];
    for (NSNumber *element in array) {
        NSLog(@"%@", element);
        [array removeObject:element];
        [array addObject:element];
    }
}

/// *** Terminating app due to uncaught exception 'NSRangeException', reason: '*** -[__NSArrayM removeObjectsInRange:]: range {0, 10} extends beyond bounds [0 .. 3]'
/// Thread 1: EXC_BAD_INSTRUCTION (code=EXC_I386_INVOP, subcode=0x0)
BG_CRASH_DEFINE_RAISE(NSRangeException, 1.2) {
    NSMutableArray *array = [NSMutableArray arrayWithObjects:@0, @1, @2, @3, nil];
    [array removeObjectsInRange:NSMakeRange(0, 10)];
}

/// *** Terminating app due to uncaught exception 'NSInvalidArgumentException', reason: '*** -[__NSPlaceholderArray initWithObjects:count:]: attempt to insert nil object from objects[0]'
/// Thread 1: EXC_BAD_INSTRUCTION (code=EXC_I386_INVOP, subcode=0x0)
BG_CRASH_DEFINE_RAISE(NSInvalidArgumentException, 1.3) {
    NSObject *element = nil;
    NSArray *arrayCrash = @[element];
    NSLog(@"%@", arrayCrash);
}

/// *** Terminating app due to uncaught exception 'NSInternalInconsistencyException', reason: 'Modifications to the layout engine must not be performed from a background thread after it has been accessed from the main thread.'
/// Thread 3: EXC_BAD_INSTRUCTION (code=EXC_I386_INVOP, subcode=0x0)
BG_CRASH_DEFINE_RAISE(NSInternalInconsistencyException, 1.4) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self.raiseCrashButton setTitle:@"" forState:UIControlStateNormal];
    });
}

/// *** Terminating app due to uncaught exception 'NSInvalidArgumentException', reason: '*** -[NSConcreteMutableData increaseLengthBy:]: absurd extra length: 18446744073709551615, maximum size: 9223372036854775808 bytes'
/// Thread 1: EXC_BAD_INSTRUCTION (code=EXC_I386_INVOP, subcode=0x0)
BG_CRASH_DEFINE_RAISE(NSMallocException, 1.5) {
    NSMutableData *data = [NSMutableData new];
    NSInteger length = NSUIntegerMax;
    [data increaseLengthBy:length];
}

BG_CRASH_DEFINE_RAISE(NSObjectInaccessibleException, 1.6) {
    NSException *exception = [NSException exceptionWithName:NSObjectInaccessibleException reason:@"CoreData Exception" userInfo:nil];
    [exception raise];
    
    NSError *error;
    for (NSInteger index = 0; index < 1000; ++index) {
        Person *person = [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:self.managedObjectContextA];
        person.name = @"Itghost";
        person.user_id = @(index).stringValue;
        person.age = 36;
        if (self.managedObjectContextA.hasChanges && ![self.managedObjectContextA save:&error]) {
            NSLog(@"%@", error);
        }
    }
    
    NSFetchRequest *fetchRequest = Person.fetchRequest;
    [fetchRequest setReturnsObjectsAsFaults:NO];
    NSArray<__kindof Person *> *persons = [self.managedObjectContextA executeFetchRequest:Person.fetchRequest error:&error];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSError *error;
        for (Person *person in persons) {
//            person.name = @"ItghostNewB";
            [self.managedObjectContextB deleteObject:person];
            [self.managedObjectContextB save:&error];
        }
    });
    
    for (Person *person in persons) {
//        person.name = @"ItghostNewA";
        [self.managedObjectContextA deleteObject:person];
        [self.managedObjectContextA save:&error];
    }
}

/// 'NSObjectNotAvailableException', reason: 'UIAlertView is deprecated and unavailable for UIScene based applications, please use UIAlertController!'
/// Thread 1: EXC_BAD_INSTRUCTION (code=EXC_I386_INVOP, subcode=0x0)
BG_CRASH_DEFINE_RAISE(NSObjectNotAvailableException, 1.7) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"" delegate:nil cancelButtonTitle:self.textCancel otherButtonTitles:self.textCancel, nil];
#pragma clang diagnostic pop
    [alertView show];
}

/// *** Terminating app due to uncaught exception 'NSDestinationInvalidException', reason: '*** -[BPCrashViewController performSelector:onThread:withObject:waitUntilDone:modes:]: target thread exited while waiting for the perform'
/// Thread 1: EXC_BAD_INSTRUCTION (code=EXC_I386_INVOP, subcode=0x0)
BG_CRASH_DEFINE_RAISE(NSDestinationInvalidException, 1.8) {
    NSThread *thread = [[NSThread alloc] initWithBlock:^{
        NSLog(@"Test NSDestinationInvalidException");
    }];
    [thread start];
    [self performSelector:@selector(testNSDestinationInvalidException) onThread:thread withObject:nil waitUntilDone:YES];
}

- (void)testNSDestinationInvalidException {
    NSLog(@"Test NSDestinationInvalidException");
}

BG_CRASH_DEFINE_RAISE(NSPortTimeoutException, 1.9) {
    NSException *exception = [NSException exceptionWithName:NSPortTimeoutException reason:@"NSConnection Exception" userInfo:nil];
    [exception raise];
}

BG_CRASH_DEFINE_RAISE(NSInvalidSendPortException, 1.10) {
    NSException *exception = [NSException exceptionWithName:NSInvalidSendPortException reason:@"NSConnection Exception" userInfo:nil];
    [exception raise];
}

BG_CRASH_DEFINE_RAISE(NSInvalidReceivePortException, 1.11) {
    NSException *exception = [NSException exceptionWithName:NSInvalidReceivePortException reason:@"NSConnection Exception" userInfo:nil];
    [exception raise];
}

BG_CRASH_DEFINE_RAISE(NSPortSendException, 1.12) {
    NSException *exception = [NSException exceptionWithName:NSPortSendException reason:@"NSConnection Exception" userInfo:nil];
    [exception raise];
}

BG_CRASH_DEFINE_RAISE(NSPortReceiveException, 1.13) {
    NSException *exception = [NSException exceptionWithName:NSPortReceiveException reason:@"NSConnection Exception" userInfo:nil];
    [exception raise];
}

BG_CRASH_DEFINE_RAISE(NSOldStyleException, 1.14) {
    NSException *exception = [NSException exceptionWithName:NSOldStyleException reason:@"Unknown Exception" userInfo:nil];
    [exception raise];
}

BG_CRASH_DEFINE_RAISE(NSInconsistentArchiveException, 1.15) {
    NSException *exception = [NSException exceptionWithName:NSInconsistentArchiveException reason:@"Unknown Exception" userInfo:nil];
    [exception raise];
}

/// *** Terminating app due to uncaught exception 'NSUnknownKeyException', reason: '[<BPCrashViewController 0x7fc5932058f0> setValue:forUndefinedKey:]: this class is not key value coding-compliant for the key Unknown Key.'
/// Thread 1: EXC_BAD_INSTRUCTION (code=EXC_I386_INVOP, subcode=0x0)
BG_CRASH_DEFINE_RAISE(NSUndefinedKeyException, 1.16) {
    [self setValue:@"Unknown Value" forKey:@"Unknown Key"];
}

/// *** Terminating app due to uncaught exception 'NSCharacterConversionException', reason: 'Conversion to encoding 30 failed'
/// Thread 1: EXC_BAD_INSTRUCTION (code=EXC_I386_INVOP, subcode=0x0)
BG_CRASH_DEFINE_RAISE(NSCharacterConversionException, 1.17) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    const char *string = @"阳光正好".cString;
    NSLog(@"%s", string);
#pragma clang diagnostic pop
}

/// *** Terminating app due to uncaught exception 'NSParseErrorException', reason: 'Error Domain=NSCocoaErrorDomain Code=3840 "Unexpected character é at line 1" UserInfo={NSDebugDescription=Unexpected character é at line 1, kCFPropertyListOldStyleParsingError=Error Domain=NSCocoaErrorDomain Code=3840 "Unexpected character '0x9633' at line 1" UserInfo={NSDebugDescription=Unexpected character '0x9633' at line 1}}'
/// Thread 1: EXC_BAD_INSTRUCTION (code=EXC_I386_INVOP, subcode=0x0)
BG_CRASH_DEFINE_RAISE(NSParseErrorException, 1.18) {
    NSDictionary *properties = @"阳光正好".propertyList;
    NSLog(@"%@", properties);
}

#pragma mark - Mach 2.0

/// Thread 1: EXC_BAD_ACCESS (code=1, address=0x0)
BG_CRASH_DEFINE_RAISE(EXC_BAD_ACCESS, 2.1) {
    char *string = NULL;
    string[0] = 'a';
}


/// Thread 8: EXC_BAD_INSTRUCTION (code=EXC_I386_INVOP, subcode=0x0)
BG_CRASH_DEFINE_RAISE(EXC_BAD_INSTRUCTION, 2.2) {
    // Invoke Multiple
    self.group = dispatch_group_create();
    dispatch_group_enter(self.group);
    dispatch_group_enter(self.group);
    dispatch_group_enter(self.group);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_group_leave(self.group);
        sleep(2);
        dispatch_group_leave(self.group);
        dispatch_group_leave(self.group);
    });
    dispatch_group_notify(self.group, dispatch_get_main_queue(), ^{
    });
}

/// Thread 1: EXC_ARITHMETIC (code=EXC_I386_DIV, subcode=0x0)
BG_CRASH_DEFINE_RAISE(EXC_ARITHMETIC, 2.3) {
   int denominator = 0;
   int numerator = 100;
   NSLog(@"%d", numerator / denominator);
}

BG_CRASH_DEFINE_RAISE(EXC_EMULATION, 2.4) {
    
}

BG_CRASH_DEFINE_RAISE(EXC_SOFTWARE, 2.5) {
    
}

BG_CRASH_DEFINE_RAISE(EXC_BREAKPOINT, 2.6) {
    
}

BG_CRASH_DEFINE_RAISE(EXC_SYSCALL, 2.7) {
    
}

BG_CRASH_DEFINE_RAISE(EXC_MACH_SYSCALL, 2.8) {
    
}

BG_CRASH_DEFINE_RAISE(EXC_RPC_ALERT, 2.9) {
    
}

BG_CRASH_DEFINE_RAISE(EXC_CRASH, 2.10) {
    
}

BG_CRASH_DEFINE_RAISE(EXC_RESOURCE, 2.11) {
    
}

BG_CRASH_DEFINE_RAISE(EXC_GUARD, 2.12) {
    
}

BG_CRASH_DEFINE_RAISE(EXC_CORPSE_NOTIFY, 2.13) {
    
}

#pragma mark - Unix Signals


BG_CRASH_DEFINE_RAISE(SIGHUP, 3.1) {
    
}

BG_CRASH_DEFINE_RAISE(SIGINT, 3.2) {
    
}

BG_CRASH_DEFINE_RAISE(SIGQUIT, 3.3) {
    
}

BG_CRASH_DEFINE_RAISE(SIGILL, 3.4) {
    
}

BG_CRASH_DEFINE_RAISE(SIGTRAP, 3.5) {
    
}

BG_CRASH_DEFINE_RAISE(SIGABRT, 3.6) {
    
}

BG_CRASH_DEFINE_RAISE(SIGPOLL, 3.7) {
    
}

BG_CRASH_DEFINE_RAISE(SIGIOT, 3.8) {
    
}

BG_CRASH_DEFINE_RAISE(SIGEMT, 3.9) {
    
}

BG_CRASH_DEFINE_RAISE(SIGFPE, 3.10) {
    
}

BG_CRASH_DEFINE_RAISE(SIGKILL, 3.11) {
    
}

BG_CRASH_DEFINE_RAISE(SIGBUS, 3.12) {
    
}

BG_CRASH_DEFINE_RAISE(SIGSEGV, 3.13) {
    
}

BG_CRASH_DEFINE_RAISE(SIGSYS, 3.14) {
    
}

BG_CRASH_DEFINE_RAISE(SIGPIPE, 3.15) {
    
}

BG_CRASH_DEFINE_RAISE(SIGALRM, 3.16) {
    
}

BG_CRASH_DEFINE_RAISE(SIGTERM, 3.17) {
    
}

BG_CRASH_DEFINE_RAISE(SIGURG, 3.18) {
    
}

BG_CRASH_DEFINE_RAISE(SIGSTOP, 3.19) {
    
}

BG_CRASH_DEFINE_RAISE(SIGTSTP, 3.20) {
    
}

BG_CRASH_DEFINE_RAISE(SIGCONT, 3.21) {
    
}

BG_CRASH_DEFINE_RAISE(SIGCHLD, 3.22) {
    
}

BG_CRASH_DEFINE_RAISE(SIGTTIN, 3.23) {
    
}

BG_CRASH_DEFINE_RAISE(SIGTTOU, 3.24) {
    
}

BG_CRASH_DEFINE_RAISE(SIGIO, 3.25) {
    
}

BG_CRASH_DEFINE_RAISE(SIGXCPU, 3.26) {
    
}

BG_CRASH_DEFINE_RAISE(SIGXFSZ, 3.27) {
    
}

BG_CRASH_DEFINE_RAISE(SIGVTALRM, 3.28) {
    
}

BG_CRASH_DEFINE_RAISE(SIGPROF, 3.29) {
    
}

BG_CRASH_DEFINE_RAISE(SIGWINCH, 3.30) {
    
}

BG_CRASH_DEFINE_RAISE(SIGINFO, 3.31) {
    
}

BG_CRASH_DEFINE_RAISE(SIGUSR1, 3.32) {
    
}

BG_CRASH_DEFINE_RAISE(SIGUSR2, 3.33) {
    
}

#pragma mark - Core Data Getter

- (NSManagedObjectContext *)managedObjectContextA {
    if (!_managedObjectContextA) {
        _managedObjectContextA = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        
        NSURL *modelPath = [[NSBundle mainBundle] URLForResource:@"BreakPadExt" withExtension:@"momd"];
        NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelPath];
        
        NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
        
        NSString *dbPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
        dbPath = [dbPath stringByAppendingPathComponent:@"BreakPadExt"];
        dbPath = [dbPath stringByAppendingPathExtension:@"db"];
        
        [coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:dbPath] options:nil error:nil];
        _managedObjectContextA.persistentStoreCoordinator = coordinator;
    }
    return _managedObjectContextA;
}
- (NSManagedObjectContext *)managedObjectContextB {
    if (!_managedObjectContextB) {
        _managedObjectContextB = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        
        NSURL *modelPath = [[NSBundle mainBundle] URLForResource:@"BreakPadExt" withExtension:@"momd"];
        NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelPath];
        
        NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
        
        NSString *dbPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
        dbPath = [dbPath stringByAppendingPathComponent:@"BreakPadExt"];
        dbPath = [dbPath stringByAppendingPathExtension:@"db"];
        
        [coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:dbPath] options:nil error:nil];
        _managedObjectContextB.persistentStoreCoordinator = coordinator;
    }
    return _managedObjectContextB;
}

#pragma mark - CSS

- (NSString *)textCancel {
    return NSLocalizedStringFromTable(@"Cancel", nil, @"取消");}
- (NSString *)textSelectCrashType {
    return NSLocalizedStringFromTable(@"Select Crash Type", nil, @"选择崩溃类型");}
// NSException
BG_CRASH_DEFINE_TEXT(NSGenericException) {
    return NSLocalizedStringFromTable(@"NSGenericException", nil, @"OC程序异常");}
BG_CRASH_DEFINE_TEXT(NSRangeException) {
    return NSLocalizedStringFromTable(@"NSRangeException", nil, @"OC程序异常");}
BG_CRASH_DEFINE_TEXT(NSInvalidArgumentException) {
    return NSLocalizedStringFromTable(@"NSInvalidArgumentException", nil, @"OC程序异常");}
BG_CRASH_DEFINE_TEXT(NSInternalInconsistencyException) {
    return NSLocalizedStringFromTable(@"NSInternalInconsistencyException", nil, @"OC程序异常");}
BG_CRASH_DEFINE_TEXT(NSMallocException) {
    return NSLocalizedStringFromTable(@"NSMallocException", nil, @"OC程序异常");}
BG_CRASH_DEFINE_TEXT(NSObjectInaccessibleException) {
    return NSLocalizedStringFromTable(@"NSObjectInaccessibleException", nil, @"OC程序异常");}
BG_CRASH_DEFINE_TEXT(NSObjectNotAvailableException) {
    return NSLocalizedStringFromTable(@"NSObjectNotAvailableException", nil, @"OC程序异常");}
BG_CRASH_DEFINE_TEXT(NSDestinationInvalidException) {
    return NSLocalizedStringFromTable(@"NSDestinationInvalidException", nil, @"OC程序异常");}
BG_CRASH_DEFINE_TEXT(NSPortTimeoutException) {
    return NSLocalizedStringFromTable(@"NSPortTimeoutException", nil, @"OC程序异常");}
BG_CRASH_DEFINE_TEXT(NSInvalidSendPortException) {
    return NSLocalizedStringFromTable(@"NSInvalidSendPortException", nil, @"OC程序异常");}
BG_CRASH_DEFINE_TEXT(NSInvalidReceivePortException) {
    return NSLocalizedStringFromTable(@"NSInvalidReceivePortException", nil, @"OC程序异常");}
BG_CRASH_DEFINE_TEXT(NSPortSendException) {
    return NSLocalizedStringFromTable(@"NSPortSendException", nil, @"OC程序异常");}
BG_CRASH_DEFINE_TEXT(NSPortReceiveException) {
    return NSLocalizedStringFromTable(@"NSPortReceiveException", nil, @"OC程序异常");}

BG_CRASH_DEFINE_TEXT(NSOldStyleException) {
    return NSLocalizedStringFromTable(@"NSOldStyleException", nil, @"OC程序异常");}
BG_CRASH_DEFINE_TEXT(NSInconsistentArchiveException) {
    return NSLocalizedStringFromTable(@"NSInconsistentArchiveException", nil, @"OC程序异常");}
BG_CRASH_DEFINE_TEXT(NSUndefinedKeyException) {
    return NSLocalizedStringFromTable(@"NSUndefinedKeyException", nil, @"OC程序异常");}
BG_CRASH_DEFINE_TEXT(NSCharacterConversionException) {
    return NSLocalizedStringFromTable(@"NSCharacterConversionException", nil, @"OC程序异常");}
BG_CRASH_DEFINE_TEXT(NSParseErrorException) {
    return NSLocalizedStringFromTable(@"NSParseErrorException", nil, @"OC程序异常");}
// Mach
BG_CRASH_DEFINE_TEXT(EXC_BAD_ACCESS) {
    return NSLocalizedStringFromTable(@"EXC_BAD_ACCESS", nil, @"非法内存访问");}
BG_CRASH_DEFINE_TEXT(EXC_BAD_INSTRUCTION) {
    return NSLocalizedStringFromTable(@"EXC_BAD_INSTRUCTION", nil, @"非法指令运行");}
BG_CRASH_DEFINE_TEXT(EXC_ARITHMETIC) {
    return NSLocalizedStringFromTable(@"EXC_ARITHMETIC", nil, @"运算");}
BG_CRASH_DEFINE_TEXT(EXC_EMULATION) {
    return NSLocalizedStringFromTable(@"EXC_EMULATION", nil, @"");}
BG_CRASH_DEFINE_TEXT(EXC_SOFTWARE) {
    return NSLocalizedStringFromTable(@"EXC_SOFTWARE", nil, @"");}
BG_CRASH_DEFINE_TEXT(EXC_BREAKPOINT) {
    return NSLocalizedStringFromTable(@"EXC_BREAKPOINT", nil, @"");}
BG_CRASH_DEFINE_TEXT(EXC_SYSCALL) {
    return NSLocalizedStringFromTable(@"EXC_SYSCALL", nil, @"");}
BG_CRASH_DEFINE_TEXT(EXC_MACH_SYSCALL) {
    return NSLocalizedStringFromTable(@"EXC_MACH_SYSCALL", nil, @"");}
BG_CRASH_DEFINE_TEXT(EXC_RPC_ALERT) {
    return NSLocalizedStringFromTable(@"EXC_RPC_ALERT", nil, @"");}
BG_CRASH_DEFINE_TEXT(EXC_CRASH) {
    return NSLocalizedStringFromTable(@"EXC_CRASH", nil, @"");}
BG_CRASH_DEFINE_TEXT(EXC_RESOURCE) {
    return NSLocalizedStringFromTable(@"EXC_RESOURCE", nil, @"");}
BG_CRASH_DEFINE_TEXT(EXC_GUARD) {
    return NSLocalizedStringFromTable(@"EXC_GUARD", nil, @"");}
BG_CRASH_DEFINE_TEXT(EXC_CORPSE_NOTIFY) {
    return NSLocalizedStringFromTable(@"EXC_CORPSE_NOTIFY", nil, @"");}
// Unix Signals
BG_CRASH_DEFINE_TEXT(SIGHUP) {
return NSLocalizedStringFromTable(@"SIGHUP", nil, @"");}
BG_CRASH_DEFINE_TEXT(SIGINT) {
return NSLocalizedStringFromTable(@"SIGINT", nil, @"");}
BG_CRASH_DEFINE_TEXT(SIGQUIT) {
return NSLocalizedStringFromTable(@"SIGQUIT", nil, @"");}
BG_CRASH_DEFINE_TEXT(SIGILL) {
return NSLocalizedStringFromTable(@"SIGILL", nil, @"");}
BG_CRASH_DEFINE_TEXT(SIGTRAP) {
return NSLocalizedStringFromTable(@"SIGTRAP", nil, @"");}
BG_CRASH_DEFINE_TEXT(SIGABRT) {
return NSLocalizedStringFromTable(@"SIGABRT", nil, @"");}
BG_CRASH_DEFINE_TEXT(SIGPOLL) {
return NSLocalizedStringFromTable(@"SIGPOLL", nil, @"");}
BG_CRASH_DEFINE_TEXT(SIGIOT) {
return NSLocalizedStringFromTable(@"SIGIOT", nil, @"");}
BG_CRASH_DEFINE_TEXT(SIGEMT) {
return NSLocalizedStringFromTable(@"SIGEMT", nil, @"");}
BG_CRASH_DEFINE_TEXT(SIGFPE) {
return NSLocalizedStringFromTable(@"SIGFPE", nil, @"");}
BG_CRASH_DEFINE_TEXT(SIGKILL) {
return NSLocalizedStringFromTable(@"SIGKILL", nil, @"");}
BG_CRASH_DEFINE_TEXT(SIGBUS) {
return NSLocalizedStringFromTable(@"SIGBUS", nil, @"");}
BG_CRASH_DEFINE_TEXT(SIGSEGV) {
return NSLocalizedStringFromTable(@"SIGSEGV", nil, @"");}
BG_CRASH_DEFINE_TEXT(SIGSYS) {
return NSLocalizedStringFromTable(@"SIGSYS", nil, @"");}
BG_CRASH_DEFINE_TEXT(SIGPIPE) {
return NSLocalizedStringFromTable(@"SIGPIPE", nil, @"");}
BG_CRASH_DEFINE_TEXT(SIGALRM) {
return NSLocalizedStringFromTable(@"SIGALRM", nil, @"");}
BG_CRASH_DEFINE_TEXT(SIGTERM) {
return NSLocalizedStringFromTable(@"SIGTERM", nil, @"");}
BG_CRASH_DEFINE_TEXT(SIGURG) {
return NSLocalizedStringFromTable(@"SIGURG", nil, @"");}
BG_CRASH_DEFINE_TEXT(SIGSTOP) {
return NSLocalizedStringFromTable(@"SIGSTOP", nil, @"");}
BG_CRASH_DEFINE_TEXT(SIGTSTP) {
return NSLocalizedStringFromTable(@"SIGTSTP", nil, @"");}
BG_CRASH_DEFINE_TEXT(SIGCONT) {
return NSLocalizedStringFromTable(@"SIGCONT", nil, @"");}
BG_CRASH_DEFINE_TEXT(SIGCHLD) {
return NSLocalizedStringFromTable(@"SIGCHLD", nil, @"");}
BG_CRASH_DEFINE_TEXT(SIGTTIN) {
return NSLocalizedStringFromTable(@"SIGTTIN", nil, @"");}
BG_CRASH_DEFINE_TEXT(SIGTTOU) {
return NSLocalizedStringFromTable(@"SIGTTOU", nil, @"");}
BG_CRASH_DEFINE_TEXT(SIGIO) {
return NSLocalizedStringFromTable(@"SIGIO", nil, @"");}
BG_CRASH_DEFINE_TEXT(SIGXCPU) {
return NSLocalizedStringFromTable(@"SIGXCPU", nil, @"");}
BG_CRASH_DEFINE_TEXT(SIGXFSZ) {
return NSLocalizedStringFromTable(@"SIGXFSZ", nil, @"");}
BG_CRASH_DEFINE_TEXT(SIGVTALRM) {
return NSLocalizedStringFromTable(@"SIGVTALRM", nil, @"");}
BG_CRASH_DEFINE_TEXT(SIGPROF) {
return NSLocalizedStringFromTable(@"SIGPROF", nil, @"");}
BG_CRASH_DEFINE_TEXT(SIGWINCH) {
return NSLocalizedStringFromTable(@"SIGWINCH", nil, @"");}
BG_CRASH_DEFINE_TEXT(SIGINFO) {
return NSLocalizedStringFromTable(@"SIGINFO", nil, @"");}
BG_CRASH_DEFINE_TEXT(SIGUSR1) {
return NSLocalizedStringFromTable(@"SIGUSR1", nil, @"");}
BG_CRASH_DEFINE_TEXT(SIGUSR2) {
return NSLocalizedStringFromTable(@"SIGUSR2", nil, @"");}

@end
