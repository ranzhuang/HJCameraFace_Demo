//
//  HJCameraTakingMovie.m
//  HJCameraFace_Demo
//
//  Created by MDLK-HJ on 2018/4/23.
//  Copyright © 2018年 黄炬. All rights reserved.
//

#import "HJCameraTakingMovie.h"

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
@interface HJCameraTakingMovie()<AVCaptureFileOutputRecordingDelegate,AVCaptureAudioDataOutputSampleBufferDelegate>
@property (nonatomic, strong) AVCaptureDeviceInput *audioInput;
/**
 视频输出
 */
@property (nonatomic, strong) AVCaptureMovieFileOutput *moviewOutpu;
//失败回调
@property (nonatomic, copy) errorBlock errorCallback;
//写入视频成功的回调
@property (nonatomic, copy) void (^saveVideoSuccess)(NSString *videoPath);
@end

@implementation HJCameraTakingMovie

- (BOOL)creatSession:(NSError *__autoreleasing *)error {
    if (self.input) {
        if ([self.session canAddInput:self.input]) {
            [self.session addInput:self.input];
        }
    } else {
        return NO;
    }
    if (self.moviewOutpu) {
        if ([self.session canAddOutput:self.moviewOutpu]) {
            [self.session addOutput:self.moviewOutpu];
        }
    } else {
        return NO;
    }
    if (self.audioInput) {
        if ([self.session canAddInput:self.audioInput]) {
            [self.session addInput:self.audioInput];
        }
    } else {
        return NO;
    }
    return YES;
}


/**
 是否正在记录
 
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
    if (![self isRecording]) {
        //开始录制
        [self.moviewOutpu startRecordingToOutputFileURL:getFileUrl() recordingDelegate:self];
    }
    
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
    
    if (self.errorCallback) {
        self.errorCallback = ^(NSError *error) {
            errorCallback(error);
        };
    } else {
        self.saveVideoSuccess = ^(NSString *videoPath) {
            successCallback(videoPath);
        };
    }
    
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {

    if (error) {
        if (self.errorCallback) {
            self.errorCallback(error);
            
        }
    } else {
        if (self.saveVideoSuccess) {
            self.saveVideoSuccess(videoPath);
        }
    }
    
}

#pragma mark - get
- (AVCaptureMovieFileOutput *)moviewOutpu {
    if (!_moviewOutpu) {
        _moviewOutpu = [[AVCaptureMovieFileOutput alloc] init];
    }
    return _moviewOutpu;
}

- (AVCaptureDeviceInput *)audioInput {
    if (!_audioInput) {
        AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
        NSError *error;
        _audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
        if (error) {
            NSLog(@"获取麦克风失败");
        }
    }
    return _audioInput;
}

@end
