//
//  HJFaceViewController.m
//  HJCameraFace_Demo
//
//  Created by MDLK-HJ on 2018/4/20.
//  Copyright © 2018年 黄炬. All rights reserved.
//

#import "HJFaceViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "HJPreviewView.h"
#import "HJCameraTakingFace.h"

@interface HJFaceViewController ()<HJCameraTakingFaceDelegate>

@property (nonatomic, strong) HJPreviewView *faceView;
@property (nonatomic, strong) HJCameraTakingFace *faceTool;

@end

@implementation HJFaceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.faceTool = [[HJCameraTakingFace alloc] init];
    if ([self.faceTool creatSession:nil]) {
        self.faceTool.delegate = self;
        [self.view.layer insertSublayer:self.faceTool.previewLayer atIndex:0];
        [self.faceTool startSession];
    }
}
#pragma mark - HJCameraTakingFaceDelegate
- (void)cameraDidOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects {
    [self.faceView showPreviewWithFaces:metadataObjects withVideoLayer:self.faceTool.previewLayer];
}

- (HJPreviewView *)faceView {
    if (!_faceView) {
        _faceView = [[HJPreviewView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
        [self.view addSubview:_faceView];
    }
    return _faceView;
}

@end
