//
//  ViewController.m
//  HJCameraFace_Demo
//
//  Created by 黄炬 on 2018/4/18.
//  Copyright © 2018年 黄炬. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "HJPreviewView.h"

@interface ViewController ()<AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDeviceInput *input;
@property (nonatomic, strong) AVCaptureMetadataOutput *dataOutput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoLayer;
@property (nonatomic, strong) HJPreviewView *faceView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setCamera];
}

#pragma mark - 开启相机
- (void)setCamera {
    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    }
    if ([self.session canAddOutput:self.dataOutput]) {
        [self.session addOutput:self.dataOutput];
        for (AVMetadataObjectType type in self.dataOutput.availableMetadataObjectTypes) {
            if (type == AVMetadataObjectTypeFace) {
                _dataOutput.metadataObjectTypes = @[type];
            }
        }
    }
    [self.view.layer addSublayer:self.videoLayer];
    if (![self.session isRunning]) {
        [self.session startRunning];
    }
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    [self.faceView showPreviewWithFaces:metadataObjects withVideoLayer:self.videoLayer];
}

#pragma mark - set & get
- (AVCaptureDevice *)device {
    if (!_device) {
        //如果有前置摄像头，返回前置摄像头
        if([AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo].count > 1) {
            for (AVCaptureDevice *tempDevice in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
                if (tempDevice.position == AVCaptureDevicePositionFront) {
                    _device = tempDevice;
                }
            }
        }
    }
    return _device;
}

- (AVCaptureSession *)session {
    if (!_session) {
        _session = [[AVCaptureSession alloc] init];
        [_session setSessionPreset:AVCaptureSessionPresetHigh];
    }
    return _session;
}

- (AVCaptureDeviceInput *)input {
    if (!_input) {
        _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    }
    return _input;
}

- (AVCaptureMetadataOutput *)dataOutput {
    if (!_dataOutput) {
        _dataOutput = [[AVCaptureMetadataOutput alloc]init];
        [_dataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    }
    return _dataOutput;
}

- (AVCaptureVideoPreviewLayer *)videoLayer {
    if (!_videoLayer) {
        _videoLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
        _videoLayer.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    }
    return _videoLayer;
}

- (HJPreviewView *)faceView {
    if (!_faceView) {
        _faceView = [[HJPreviewView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
        [self.view addSubview:_faceView];
    }
    return _faceView;
}


@end
