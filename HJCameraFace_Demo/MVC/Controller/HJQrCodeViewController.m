//
//  HJQrCodeViewController.m
//  HJCameraFace_Demo
//
//  Created by MDLK-HJ on 2018/4/20.
//  Copyright © 2018年 黄炬. All rights reserved.
//

#import "HJQrCodeViewController.h"
#import "HJCameraQrCodeTool.h"
#import "HJQrMainView.h"

@interface HJQrCodeViewController ()<HJCameraQrCodeToolDelegate>

@property (nonatomic, strong) HJCameraQrCodeTool *qrCodeTool;
@property (nonatomic, strong) HJQrMainView *mainView;

@end

@implementation HJQrCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    self.qrCodeTool = [[HJCameraQrCodeTool alloc] init];
    self.qrCodeTool.delegate = self;
    if ([self.qrCodeTool creatSession:nil]) {
        [self.view.layer addSublayer:self.qrCodeTool.previewLayer];
        [self.view addSubview:self.mainView];
        [self.qrCodeTool startSession];
    }
}
- (void)viewWillDisappear:(BOOL)animated {
    [self.qrCodeTool stopSession];
}

#pragma mark - HJCameraQrCodeToolDelegate
- (void)cameraQrcodeDidGetResultWithString:(NSString *)str {
    NSLog(@"%@",str);
    [self.mainView stopAnimation];
}

- (HJQrMainView *)mainView {
    if (!_mainView) {
        _mainView = [[HJQrMainView alloc] initWithFrame:self.view.bounds];
    }
    return _mainView;
}

@end
