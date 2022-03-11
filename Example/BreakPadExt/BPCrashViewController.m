//
//  BPCrashViewController.m
//  BreakPadExt
//
//  Created by ItghostFan on 03/09/2022.
//  Copyright (c) 2022 ItghostFan. All rights reserved.
//

#import "BPCrashViewController.h"

#import <ReactiveObjC/ReactiveObjC.h>
#import <Masonry/Masonry.h>

@interface BPCrashViewController ()

@property (weak, nonatomic) IBOutlet UIButton *crashTypeButton;
@property (weak, nonatomic) IBOutlet UIButton *raiseCrashButton;

@property (strong, nonatomic) NSMutableDictionary<__kindof NSString *, __kindof UIAlertAction *> *crashTypeActions;
@property (strong, nonatomic) NSMutableDictionary<__kindof NSString *, __kindof NSString *> *crashActions;

@end

@implementation BPCrashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.crashTypeActions = [NSMutableDictionary new];
    self.crashActions = [NSMutableDictionary new];
    [self makeUI];
    [self makeActions];
    
    [self addCrashType:self.textNSException selector:@selector(raiseNSException)];
    [self addCrashType:self.textArithmetic selector:@selector(raiseArithmetic)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Make UI

- (void)makeUI {
    [self.crashTypeButton setTitle:self.textNSException forState:UIControlStateNormal];
    
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

/// *** Terminating app due to uncaught exception 'NSInvalidArgumentException', reason: '*** -[__NSPlaceholderArray initWithObjects:count:]: attempt to insert nil object from objects[0]'
- (void)raiseNSException {
    NSObject *element = nil;
    NSArray *arrayCrash = @[element];
    NSLog(@"%@", arrayCrash);
}


/// Thread 1: EXC_ARITHMETIC (code=EXC_I386_DIV, subcode=0x0)
- (void)raiseArithmetic {
    int denominator = 0;
    int numerator = 100;
    NSLog(@"%d", numerator / denominator);
}

#pragma mark - CSS

- (NSString *)textCancel            { return NSLocalizedStringFromTable(@"Cancel", nil, @"取消"); }
- (NSString *)textSelectCrashType   { return NSLocalizedStringFromTable(@"Select Crash Type", nil, @"选择崩溃类型"); }
- (NSString *)textNSException       { return NSLocalizedStringFromTable(@"NSException", nil, @"OC程序异常"); }
- (NSString *)textArithmetic        { return NSLocalizedStringFromTable(@"Arithmetic", nil, @"运算"); }

@end
