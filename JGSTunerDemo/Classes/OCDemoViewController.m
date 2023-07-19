//
//  OCDemoViewController.m
//  JGSTunerDemo
//
//  Created by 梅继高 on 2023/6/28.
//  Copyright © 2023 MeiJigao. All rights reserved.
//

#import "OCDemoViewController.h"
#import <JGSourceBase/JGSourceBase.h>
@import JGSTuner;

@interface OCDemoViewController ()

@property (nonatomic, strong) JGSTuner *tuner;

@end

@implementation OCDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.title = @"Demo-OC";
    self.view.backgroundColor = [UIColor colorWithWhite:0.99 alpha:1.0];
    
    _tuner = [[JGSTuner alloc] initWithMicrophoneAccessAlert:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (_tuner.didReceiveAudio) {
        [_tuner stop];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    if (_tuner.didReceiveAudio) {
        [_tuner stop];
    } else {
        
        [_tuner startWithAmplitudeThreshold:0.025 a4Frequency:440 analyzeCallback:^(float frequency, float amplitude, NSArray<NSString *> *_Nonnull names, NSInteger octave, float distance, float standardFrequency) {
            JGSLog(@"%f, %f", frequency, amplitude);
        } completionHandler:^(BOOL success) {
            JGSLog(@"Start %@", success ? @"success" : @"fail");
        }];
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
