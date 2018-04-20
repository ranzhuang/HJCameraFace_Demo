//
//  HJCameraTakingPicture.m
//  HJCameraForImageDemo
//
//  Created by 黄炬 on 2018/4/9.
//  Copyright © 2018年 黄炬. All rights reserved.
//

#import "HJCameraTakingPicture.h"


#define HJVersion(value) [UIDevice currentDevice].systemVersion.floatValue >= (value)


/**
 获取图片方向

 @return return value description
 */
static inline AVCaptureVideoOrientation currentVideoOrientation() {
    //通过设备的方向去修正图片的方向
    AVCaptureVideoOrientation orientation;
    switch ([[UIDevice currentDevice] orientation]) {
        case UIDeviceOrientationPortrait:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            orientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        case UIDeviceOrientationLandscapeRight:
            orientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        default:
            orientation = AVCaptureVideoOrientationLandscapeRight;
            break;
    }
    return orientation;
}

/**
 获取地址url

 @return url
 */
static inline NSURL * getFileUrl() {
    NSString *dirPath = [NSTemporaryDirectory() stringByAppendingString:@"tempCamera"];
    if (dirPath) {
        if (![[NSFileManager defaultManager] fileExistsAtPath:dirPath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        NSString *filePath = [dirPath stringByAppendingPathComponent:@"HJCamera_movie.mov"];
        if ([[NSFileManager defaultManager] isExecutableFileAtPath:filePath]) {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
        return [NSURL fileURLWithPath:filePath];
    }
    return nil;
    
}

@interface HJCameraTakingPicture()<AVCaptureFileOutputRecordingDelegate>
/**
 输出
 */
@property (nonatomic, strong) AVCaptureStillImageOutput *imageOutput;
/**
 视频输出
 */
@property (nonatomic, strong) AVCaptureMovieFileOutput *moviewOutpu;

//获取图片成功回调
@property (nonatomic, copy) successBlock successCallback;
//失败回调
@property (nonatomic, copy) errorBlock errorCallback;
//写入视频成功的回调
@property (nonatomic, copy) void (^saveVideoSuccess)(NSString *videoPath);
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
    
    self.moviewOutpu = [[AVCaptureMovieFileOutput alloc] init];
    if (self.moviewOutpu) {
        if ([self.session canAddOutput:self.moviewOutpu]) {
            [self.session addOutput:self.moviewOutpu];
        }
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
        connection.videoOrientation = currentVideoOrientation();
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
    self.successCallback = ^(UIImage *image) {
        successCallback(image);
    };
    self.errorCallback = ^(NSError *error) {
        errorCallback(error);
    };
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (self.successCallback) {
        self.successCallback(image);
    }
    if (self.errorCallback) {
        self.errorCallback(error);
    }
}


/**
 是否能记录

 @return YES or NO
 */
- (BOOL)isRecording {
    return [self.moviewOutpu isRecording];
}

/**
 开始记录
 */
- (void)startRecording {
    //设置connection
    AVCaptureConnection *connection = [self.moviewOutpu connectionWithMediaType:AVMediaTypeVideo];
    //是否支持设置videoOrientation
    if ([connection isVideoOrientationSupported]) {
        [connection setVideoOrientation:currentVideoOrientation()];
    }
    //是否支持视频稳定
    if ([connection isVideoStabilizationSupported]) {
        [connection setPreferredVideoStabilizationMode:AVCaptureVideoStabilizationModeAuto];
    }
    //摄像头是否支持平滑对焦
    AVCaptureDevice *device = self.input.device;
    if ([device isSmoothAutoFocusSupported]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            [device setSmoothAutoFocusEnabled:YES];
            [device unlockForConfiguration];
        }
    }
    [self.moviewOutpu startRecordingToOutputFileURL:getFileUrl() recordingDelegate:self];
}

/**
 停止记录
 */
- (void)stopRecording {
    if ([self isRecording]) {
        [self.moviewOutpu stopRecording];
    }
}

#pragma mark - AVCaptureFileOutputRecordingDelegate

/**
 结束录制

 @param output output description
 @param outputFileURL outputFileURL description
 @param connections connections description
 @param error error description
 */
- (void)captureOutput:(AVCaptureFileOutput *)output didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections error:(NSError *)error {
    if (self.finishRecord) {
        self.finishRecord(outputFileURL, error);
    }
}

/**
 将视频写入相册

 @param videoUrl videoUrl description
 */
- (void)writeMovieToLibrary:(NSURL *)videoUrl success:(void (^)(NSString *))successCallback error:(errorBlock)errorCallback {
    NSString *dirPath = [NSTemporaryDirectory() stringByAppendingString:@"tempCamera"];
    NSString *filePath = [dirPath stringByAppendingPathComponent:@"HJCamera_movie.mov"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(filePath)) {
            dispatch_async(dispatch_queue_create(nil, DISPATCH_QUEUE_PRIORITY_DEFAULT), ^{
                UISaveVideoAtPathToSavedPhotosAlbum(filePath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
            });
        }else {
            NSLog(@"不能保存");
        }
    }
    self.saveVideoSuccess = ^(NSString *videoPath) {
        successCallback(videoPath);
    };
    self.errorCallback = ^(NSError *error) {
        errorCallback(error);
    };
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (self.errorCallback) {
        self.errorCallback(error);
        
    }
    if (self.saveVideoSuccess) {
        self.saveVideoSuccess(videoPath);
    }
}


@end
