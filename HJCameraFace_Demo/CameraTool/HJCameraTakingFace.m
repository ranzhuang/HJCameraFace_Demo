//
//  HJCameraTakingFace.m
//  HJCameraFace_Demo
//
//  Created by MDLK-HJ on 2018/4/23.
//  Copyright © 2018年 黄炬. All rights reserved.
//

#import "HJCameraTakingFace.h"

@interface HJCameraTakingFace()<AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) AVCaptureMetadataOutput *dataOutput;


@end

@implementation HJCameraTakingFace

- (BOOL)creatSession:(NSError *__autoreleasing *)error {
    if (self.input) {
        if ([self.session canAddInput:self.input]) {
            [self.session addInput:self.input];
        }
    } else {
        return NO;
    }
    if (self.dataOutput) {
        if ([self.session canAddOutput:self.dataOutput]) {
            [self.session addOutput:self.dataOutput];
            for (AVMetadataObjectType type in self.dataOutput.availableMetadataObjectTypes) {
                if (type == AVMetadataObjectTypeFace) {
                    _dataOutput.metadataObjectTypes = @[type];
                }
            }
        }
    } else {
        return NO;
    }
    return YES;
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if ([self.delegate respondsToSelector:@selector(cameraDidOutputMetadataObjects:)]) {
        [self.delegate cameraDidOutputMetadataObjects:metadataObjects];
    }
}

#pragma mark - get
- (AVCaptureMetadataOutput *)dataOutput {
    if (!_dataOutput) {
        _dataOutput = [[AVCaptureMetadataOutput alloc]init];
        [_dataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    }
    return _dataOutput;
}
@end
