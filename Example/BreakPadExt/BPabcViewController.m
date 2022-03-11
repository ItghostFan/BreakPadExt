//
//  BPabcViewController.m
//  BreakPadExt
//
//  Created by ItghostFan on 03/09/2022.
//  Copyright (c) 2022 ItghostFan. All rights reserved.
//

#import "BPabcViewController.h"

#import <ReactiveObjC/ReactiveObjC.h>

@interface BPabcViewController ()

@property (weak, nonatomic) IBOutlet UIButton *makeCrashButton;

@end

@implementation BPabcViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.makeCrashButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        NSObject *element = nil;
        NSArray *arrayCrash = @[element];
        NSLog(@"%@", arrayCrash);
        return RACSignal.empty;
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
