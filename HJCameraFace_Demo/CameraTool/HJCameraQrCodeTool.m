//
//  HJCameraQrCodeTool.m
//  HJCamera_Demo
//
//  Created by MDLK-HJ on 2018/4/20.
//  Copyright © 2018年 MDLK-HJ. All rights reserved.
//

#import "HJCameraQrCodeTool.h"

@interface  HJCameraQrCodeTool()<AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) AVCaptureMetadataOutput *output;

@end

@implementation HJCameraQrCodeTool

#pragma mark - 实现父类方法
- (BOOL)creatSession:(NSError *__autoreleasing *)error {
    if (self.session) {
        if (self.input) {
            if ([self.session canAddInput:self.input]) {
                [self.session addInput:self.input];
            } else {
                return NO;
            }
        }
        if (self.output) {
            if ([self.session canAddOutput:self.output]) {
                [self.session addOutput:self.output];
                //RectOfInterest默认值时（0，0，1，1）
                //AVCapture输出的图片大小都是横着的，而iPhone的屏幕是竖着的，那么我把它旋转90°呢
                //可以理解为（y,x,height,width）
                CGRect rect = CGRectMake(HJQrY / HJScreenHeight, HJQrX / HJScreenWidth, HJQrWidth / HJScreenHeight, HJQrWidth / HJScreenWidth);
                [self.output setRectOfInterest:rect];
                NSMutableArray *typeArray = [NSMutableArray array];
                for (AVMetadataObjectType type in [self.output availableMetadataObjectTypes]) {
                    //第一个为二维码，其他为条形码识别
                    if (type == AVMetadataObjectTypeQRCode          || type == AVMetadataObjectTypeEAN8Code    ||
                        type == AVMetadataObjectTypeEAN13Code       || type == AVMetadataObjectTypeCode39Code  ||
                        type == AVMetadataObjectTypeCode93Code      || type == AVMetadataObjectTypeCode128Code ||
                        type == AVMetadataObjectTypeCode39Mod43Code || type == AVMetadataObjectTypeUPCECode    ||
                        type == AVMetadataObjectTypePDF417Code ) {
                        [typeArray addObject:type];
                    }
                }
                [self.output setMetadataObjectTypes:typeArray];
            } else {
                return NO;
            }
        }
        return YES;
    }
    return NO;
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex : 0 ];
    [self stopSession];
    if ([self.delegate respondsToSelector:@selector(cameraQrcodeDidGetResultWithString:)]) {
        [self.delegate cameraQrcodeDidGetResultWithString:metadataObject.stringValue];
    }
}

#pragma mark - get
- (AVCaptureMetadataOutput *)output {
    if (!_output) {
        _output = [[AVCaptureMetadataOutput alloc] init];
        [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    }
    return _output;
}

@end
