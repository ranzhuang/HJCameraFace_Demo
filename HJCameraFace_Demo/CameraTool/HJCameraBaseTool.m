//
//  HJCameraBaseTool.m
//  HJCamera_Demo
//
//  Created by MDLK-HJ on 2018/4/20.
//  Copyright © 2018年 MDLK-HJ. All rights reserved.
//

#import "HJCameraBaseTool.h"

static void *HJCameraAdjustingExposureContext = &HJCameraAdjustingExposureContext;

/**
 获取指定摄像头设备
 
 @param position 位置
 @return         返回设备
 */
static inline AVCaptureDevice * getCameraDeviceWithPosition(AVCaptureDevicePosition position) {
    NSArray *deviceArray = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in deviceArray) {
        if (device.position == position) {
            return device;
        }
    }
    return nil;
}

@interface HJCameraBaseTool()
/**
 线程
 */
@property (nonatomic, strong) dispatch_queue_t sessionQueue;
@end

@implementation HJCameraBaseTool

#pragma mark - 子类实现方法
- (BOOL)creatSession:(NSError *__autoreleasing *)error {
    return NO;
}
#pragma mark - 相机基本设置
/**
 开启会话
 */
- (void)startSession {
    if (![self.session isRunning]) {
        dispatch_async(self.sessionQueue, ^{
            [self.session startRunning];
        });
    }
}

/**
 关闭会话
 */
- (void)stopSession {
    if ([self.session isRunning]) {
        dispatch_async(self.sessionQueue, ^{
            [self.session stopRunning];
        });
    }
}


/**
 是否可以改变摄像头
 
 @return YES or NO
 */
- (BOOL)shouldChangeCamera {
    return [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo].count > 1;
}


/**
 切换摄像头
 
 @return 成功返回YES，失败返回NO
 */
- (BOOL)changeCamera {
    
    //获取摄像头总数量 总数大于1才可以切换摄像头
    if ([self shouldChangeCamera]) {
        //获取改变后的摄像头
        AVCaptureDevice *device;
        CATransition *animation = [CATransition animation];
        animation.duration = 0.5f;
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [animation setType:@"fade"];
        if (self.input.device.position == AVCaptureDevicePositionBack) {
            device = getCameraDeviceWithPosition(AVCaptureDevicePositionFront);
        } else {
            device = getCameraDeviceWithPosition(AVCaptureDevicePositionBack);
        }
        NSError *error;
        if (device != nil) {
            AVCaptureDeviceInput *tempInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
            if (tempInput) {
                [self.session beginConfiguration];
                [self.session removeInput:self.input];
                if ([self.session canAddInput: tempInput]) {
                    [self.session addInput:tempInput];
                    self.input = tempInput;
                } else {
                    [self.session addInput:self.input];
                }
                [self.session commitConfiguration];
                [self.previewLayer addAnimation:animation forKey:nil];
                return YES;
            }
            return NO;
        }
        return NO;
    }
    return NO;
}


/**
 是否能够对焦
 
 @return YES or NO
 */
- (BOOL)shouldFocus {
    return [self.input.device isFocusPointOfInterestSupported];
}

/**
 点击对焦
 
 @param point 坐标
 */
- (void)focusAtPoint:(CGPoint)point {
    //获取当前设备
    AVCaptureDevice *device = self.input.device;
    if (device.isFocusPointOfInterestSupported &&
        [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.focusPointOfInterest = point;
            [device setFocusMode:AVCaptureFocusModeAutoFocus];
            [device unlockForConfiguration];
        } else {
            NSLog(@"设备发生错误");
        }
    }else {
        NSLog(@"不支持对焦");
    }
}

/**
 是否能够曝光
 
 @return YES or NO
 */
- (BOOL)shouldExpose {
    return [self.input.device isExposurePointOfInterestSupported];
}

/**
 点击曝光
 
 @param point point description
 */
- (void)exposeAtPoint:(CGPoint)point {
    //获取当前设备
    AVCaptureDevice *device = self.input.device;
    if (device.isExposurePointOfInterestSupported &&
        [device isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.exposurePointOfInterest = point;
            [device setExposureMode:AVCaptureExposureModeAutoExpose];
            //判断设备是否支持锁定曝光
            //adjustingExposure属性的状态可以让我们知道曝光调整何时完成，让我们有机会在该点上锁定曝光
            if ([device isExposureModeSupported:AVCaptureExposureModeLocked]) {
                [device addObserver:self forKeyPath:@"adjustingExposure" options:NSKeyValueObservingOptionNew context:HJCameraAdjustingExposureContext];
            }
            [device unlockForConfiguration];
        }else {
            NSLog(@"设备发生错误");
        }
    } else {
        NSLog(@"不支持曝光");
    }
}

/**
 kvo监听adjustingExposure
 
 @param keyPath keyPath description
 @param object object description
 @param change change description
 @param context context description
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (context == HJCameraAdjustingExposureContext) {
        AVCaptureDevice *device = (AVCaptureDevice *)object;
        if (!device.isAdjustingExposure &&
            [device isExposureModeSupported:AVCaptureExposureModeLocked]) {
            //移除监听
            [object removeObserver:self forKeyPath:keyPath context:context];
            //此处将exposureMode异步去完成是有必要的，这样上一步中的removeObserver调用才有机会完成。
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *error;
                if ([device lockForConfiguration:&error]) {
                    [device setExposureMode:AVCaptureExposureModeLocked];
                    [device unlockForConfiguration];
                }
            });
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


/**
 重置焦点和曝光
 */
- (void)resetFocusAndExposure {
    // 获取device
    AVCaptureDevice *device = self.input.device;
    CGPoint centerPoint = CGPointMake(0.5, 0.5);
    NSError *error;
    if ([device lockForConfiguration:&error]) {
        if ([device isFocusPointOfInterestSupported] &&
            [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            device.focusPointOfInterest = centerPoint;
            [device setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        if ([device isExposurePointOfInterestSupported] &&
            [device isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
            device.exposureMode = AVCaptureExposureModeAutoExpose;
            device.exposurePointOfInterest = centerPoint;
        }
        [device unlockForConfiguration];
    }
}

/**
 是否支持闪光
 
 @return YES or NO
 */
- (BOOL)shouldFlash {
    return [self.input.device hasFlash];
}

/**
 设置闪光模式
 
 @param flashModel flashModel description
 */
- (void)setFlashModel:(AVCaptureFlashMode)flashModel {
    AVCaptureDevice *devide = self.input.device;
    if ([devide isFlashModeSupported:flashModel]) {
        NSError *error;
        if ([devide lockForConfiguration:&error]) {
            [devide setFlashMode:flashModel];
            [devide unlockForConfiguration];
        }
    }
}

/**
 是否支持手电
 
 @return return value description
 */
- (BOOL)shouldTorch {
    return [self.init.device hasTorch];
}

/**
 设置手电模式
 
 @param torchModel torchModel description
 */
- (void)setTorchModel:(AVCaptureTorchMode)torchModel {
    AVCaptureDevice *device = self.input.device;
    if ([device isTorchModeSupported:torchModel]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.torchMode = torchModel;
            [device unlockForConfiguration];
        }
    }
}


#pragma mark - get
- (AVCaptureDevice *)device {
    if (!_device) {
        _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
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
- (AVCaptureVideoPreviewLayer *)previewLayer {
    if (!_previewLayer) {
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _previewLayer.frame = CGRectMake(0, 0, HJScreenWidth, HJScreenHeight);
    }
    return _previewLayer;
}

- (dispatch_queue_t)sessionQueue {
    if (!_sessionQueue) {
        _sessionQueue = dispatch_queue_create("sessionQueue", NULL);
    }
    return _sessionQueue;
}


@end
