//
//  OCViewController.m
//  JGSTunerDemo
//
//  Created by 梅继高 on 2023/6/26.
//  Copyright © 2023 MeiJiGao. All rights reserved.
//

#import "OCViewController.h"
#import <JGSourceBase/JGSourceBase.h>
@import JGSTuner;

UIColor * JGSColor(uint32_t hex) {
    return [UIColor colorWithRed:(((hex & 0xFF0000) >> 16) / 255.f) green:(((hex & 0xFF00) >> 8) / 255.f) blue:(((hex & 0xFF) >> 0) / 255.f) alpha:1.f];
}

@interface OCViewController ()

@property (nonatomic, strong) JGSTuner *tuner;

@end

@implementation OCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.title = @"Demo-OC";
    self.view.backgroundColor = [UIColor colorWithWhite:0.99 alpha:1.0];
    
    _tuner = [[JGSTuner alloc] initWithMicrophoneAccessAlert:^{
        JGSLog();
    }];
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
        JGSWeakSelf
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            JGSStrongSelf
            [self.tuner startWithDebug:YES completionHandler:^{
                
            }];
        });
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
