//
//  BPCrashViewController.m
//  BreakPadExt
//
//  Created by ItghostFan on 03/09/2022.
//  Copyright (c) 2022 ItghostFan. All rights reserved.
//

#import "BPCrashViewController.h"

#import <CoreData/CoreData.h>

#import <ReactiveObjC/ReactiveObjC.h>
#import <Masonry/Masonry.h>

#import "Person+CoreDataClass.h"

#define BP_CRASH_ADD_CRASH_TYPE(crashType) \
[self addCrashType:self.text##crashType selector:@selector(raise##crashType)];

#define BG_CRASH_DEFINE_RAISE(crashType) \
- (void)raise##crashType

#define BG_CRASH_DEFINE_TEXT(crashType) \
- (NSString *)text##crashType

@interface BPCrashViewController ()

@property (weak, nonatomic) IBOutlet UIButton *crashTypeButton;
@property (weak, nonatomic) IBOutlet UIButton *raiseCrashButton;

@property (strong, nonatomic) NSMutableDictionary<__kindof NSString *, __kindof UIAlertAction *> *crashTypeActions;
@property (strong, nonatomic) NSMutableDictionary<__kindof NSString *, __kindof NSString *> *crashActions;

#pragma mark - Core Data Properties

@property(nonatomic, strong) NSManagedObjectContext *managedObjectContextA;
@property(nonatomic, strong) NSManagedObjectContext *managedObjectContextB;

@end

@implementation BPCrashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.crashTypeActions = [NSMutableDictionary new];
    self.crashActions = [NSMutableDictionary new];
    [self makeUI];
    [self makeActions];
    
    BP_CRASH_ADD_CRASH_TYPE(NSGenericException);
    BP_CRASH_ADD_CRASH_TYPE(NSRangeException);
    BP_CRASH_ADD_CRASH_TYPE(NSInvalidArgumentException);
    BP_CRASH_ADD_CRASH_TYPE(NSInternalInconsistencyException);
    BP_CRASH_ADD_CRASH_TYPE(NSMallocException);
    BP_CRASH_ADD_CRASH_TYPE(NSObjectInaccessibleException);
    BP_CRASH_ADD_CRASH_TYPE(NSObjectNotAvailableException);
    
    BP_CRASH_ADD_CRASH_TYPE(Arithmetic);
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
        [self.crashTypeActions enumerateKeysAndObjectsUsingBlock:^(__kindof NSString * _Nonnull key, __kindof UIAlertAction * _Nonnull obj, BOOL * _Nonnull stop) {
            [controller addAction:obj];
        }];
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

- (void)addCrashType:(NSString *)crashType selector:(SEL)selector {
    @weakify(self);
    self.crashTypeActions[crashType] = [UIAlertAction actionWithTitle:crashType style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        @strongify(self);
        [self.crashTypeButton setTitle:crashType forState:UIControlStateNormal];
    }];
    self.crashActions[crashType] = NSStringFromSelector(selector);
}

#pragma mark - NSException

/// *** Terminating app due to uncaught exception 'NSGenericException', reason: '*** Collection <__NSArrayM: 0x6000025ea5e0> was mutated while being enumerated.'
/// Thread 1: EXC_BAD_INSTRUCTION (code=EXC_I386_INVOP, subcode=0x0)
BG_CRASH_DEFINE_RAISE(NSGenericException) {
    NSMutableArray *array = [NSMutableArray arrayWithObjects:@0, @1, @2, @3, nil];
    for (NSNumber *element in array) {
        NSLog(@"%@", element);
        [array removeObject:element];
        [array addObject:element];
    }
}

/// *** Terminating app due to uncaught exception 'NSRangeException', reason: '*** -[__NSArrayM removeObjectsInRange:]: range {0, 10} extends beyond bounds [0 .. 3]'
/// Thread 1: EXC_BAD_INSTRUCTION (code=EXC_I386_INVOP, subcode=0x0)
BG_CRASH_DEFINE_RAISE(NSRangeException) {
    NSMutableArray *array = [NSMutableArray arrayWithObjects:@0, @1, @2, @3, nil];
    [array removeObjectsInRange:NSMakeRange(0, 10)];
}

/// *** Terminating app due to uncaught exception 'NSInvalidArgumentException', reason: '*** -[__NSPlaceholderArray initWithObjects:count:]: attempt to insert nil object from objects[0]'
/// Thread 1: EXC_BAD_INSTRUCTION (code=EXC_I386_INVOP, subcode=0x0)
BG_CRASH_DEFINE_RAISE(NSInvalidArgumentException) {
    NSObject *element = nil;
    NSArray *arrayCrash = @[element];
    NSLog(@"%@", arrayCrash);
}

/// *** Terminating app due to uncaught exception 'NSInternalInconsistencyException', reason: 'Modifications to the layout engine must not be performed from a background thread after it has been accessed from the main thread.'
/// Thread 3: EXC_BAD_INSTRUCTION (code=EXC_I386_INVOP, subcode=0x0)
BG_CRASH_DEFINE_RAISE(NSInternalInconsistencyException) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self.raiseCrashButton setTitle:@"" forState:UIControlStateNormal];
    });
}

/// *** Terminating app due to uncaught exception 'NSInvalidArgumentException', reason: '*** -[NSConcreteMutableData increaseLengthBy:]: absurd extra length: 18446744073709551615, maximum size: 9223372036854775808 bytes'
/// Thread 1: EXC_BAD_INSTRUCTION (code=EXC_I386_INVOP, subcode=0x0)
BG_CRASH_DEFINE_RAISE(NSMallocException) {
    NSMutableData *data = [NSMutableData new];
    NSInteger length = NSUIntegerMax;
    [data increaseLengthBy:length];
}

/// *** Terminating app due to uncaught exception 'NSObjectInaccessibleException', reason: 'CoreData Exception'
/// Thread 1: EXC_BAD_INSTRUCTION (code=EXC_I386_INVOP, subcode=0x0)
BG_CRASH_DEFINE_RAISE(NSObjectInaccessibleException) {
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
BG_CRASH_DEFINE_RAISE(NSObjectNotAvailableException) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"" delegate:nil cancelButtonTitle:self.textCancel otherButtonTitles:self.textCancel, nil];
#pragma clang diagnostic pop
    [alertView show];
}

#pragma mark - Mach

/// Thread 1: EXC_ARITHMETIC (code=EXC_I386_DIV, subcode=0x0)
BG_CRASH_DEFINE_RAISE(Arithmetic) {
    int denominator = 0;
    int numerator = 100;
    NSLog(@"%d", numerator / denominator);
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


- (NSString *)textArithmetic {
    return NSLocalizedStringFromTable(@"Arithmetic", nil, @"运算");}

@end
