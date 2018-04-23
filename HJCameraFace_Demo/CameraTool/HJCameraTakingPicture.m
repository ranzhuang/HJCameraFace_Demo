//
//  HJCameraTakingPicture.m
//  HJCameraForImageDemo
//
//  Created by 黄炬 on 2018/4/9.
//  Copyright © 2018年 黄炬. All rights reserved.
//

#import "HJCameraTakingPicture.h"


#define HJVersion(value) [UIDevice currentDevice].systemVersion.floatValue >= (value)



@interface HJCameraTakingPicture( )
/**
 输出
 */
@property (nonatomic, strong) AVCaptureStillImageOutput *imageOutput;
//获取图片成功回调
@property (nonatomic, copy) successBlock successCallback;
//失败回调
@property (nonatomic, copy) errorBlock errorCallback;

@end

@implementation HJCameraTakingPicture

/**
 创建会话

 @param error error
 @return      返回YES代表成功，NO代表失败
 */
- (BOOL)creatSession:(NSError **)error {
    //如果input不为空
    if (self.input) {
        if ([self.session canAddInput:self.input]) {
            [self.session addInput:self.input];
        }
    } else {
        //未获取到输入设备
        return NO;
    }
    
    self.imageOutput = [[AVCaptureStillImageOutput alloc] init];
    [self.imageOutput setOutputSettings:@{AVVideoCodecKey:AVVideoCodecJPEG}];
    //如果输出不为空
    if (self.imageOutput) {
        if ([self.session canAddOutput:self.imageOutput]) {
            [self.session addOutput:self.imageOutput];
        }
    } else {
        return NO;
    }
    return YES;
}

/**
 捕捉静态图片

 @param successCallback 成功回调返回一张图片
 */
- (void)getStillImage:(successBlock)successCallback {
    //通过图片的输出创建捕捉连接
    AVCaptureConnection *connection = [self.imageOutput connectionWithMediaType:AVMediaTypeVideo];
    //修正方向
    if (connection.isVideoOrientationSupported) {
        [connection setVideoOrientation:currentVideoOrientation()];
    }
    //接受一个有效的imageDataSampleBuffer
    [self.imageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef  _Nullable imageDataSampleBuffer, NSError * _Nullable error) {
        //jpegStillImageNSDataRepresentation返回一个表示图片字节的data;
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage *image = [UIImage imageWithData:imageData];
        successCallback(image);
    }];
}

/**
 保存图片到相册

 @param image image description
 */
- (void)savaToLiraryWithImage:(UIImage *)image success:(successBlock)successCallback error:(errorBlock)errorCallback{
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    if (self.errorCallback != nil) {
        self.errorCallback = ^(NSError *error) {
            errorCallback(error);
        };
    } else {
        self.successCallback = ^(UIImage *image) {
            successCallback(image);
        };
    }
    
    
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        if (self.errorCallback) {
            self.errorCallback(error);
        }
    }else {
        if (self.successCallback) {
            self.successCallback(image);
        }
    }

}

@end
