//
//  HJGPUVideoViewController.m
//  HJCameraFace_Demo
//
//  Created by MDLK-HJ on 2018/4/24.
//  Copyright © 2018年 黄炬. All rights reserved.
//

#import "HJGPUVideoViewController.h"

@interface HJGPUVideoViewController () <LFLiveSessionDelegate>

@property (nonatomic, strong) LFLiveSession * session;

@end

@implementation HJGPUVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setCamera];
    [self startLive];
    [self.session setRunning:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

/**
 配置设备
 */
- (void)setCamera {
    self.session = [[LFLiveSession alloc] initWithAudioConfiguration:[LFLiveAudioConfiguration defaultConfiguration] videoConfiguration:[LFLiveVideoConfiguration defaultConfiguration] captureType:LFLiveCaptureDefaultMask];
    self.session.delegate = self;
    self.session.preView = self.view;
    self.session.beautyFace = YES;
    self.session.beautyLevel = 1.0;
    self.session.brightLevel = 1.0;
}

- (void)startLive {
    LFLiveStreamInfo *info = [[LFLiveStreamInfo alloc] init];
    info.url = @"";
    [self.session startLive:info];
}

- (void)stopLive {
    [self.session stopLive];
}

#pragma mark - LFLiveSessionDelegate
- (void)liveSession:(LFLiveSession *)session liveStateDidChange:(LFLiveState)state {
    
}
- (void)liveSession:(LFLiveSession *)session debugInfo:(LFLiveDebug *)debugInfo {
    
}
- (void)liveSession:(LFLiveSession *)session errorCode:(LFLiveSocketErrorCode)errorCode {
    
}
@end
