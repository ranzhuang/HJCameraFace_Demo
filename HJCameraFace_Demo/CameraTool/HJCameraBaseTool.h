//
//  HJCameraBaseTool.h
//  HJCamera_Demo
//
//  Created by MDLK-HJ on 2018/4/20.
//  Copyright © 2018年 MDLK-HJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

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

@interface HJCameraBaseTool : NSObject
/**
 设备
 */
@property (nonatomic, strong) AVCaptureDevice *device;
/**
 会话
 */
@property (nonatomic, strong) AVCaptureSession *session;
/**
 输入
 */
@property (nonatomic, strong) AVCaptureDeviceInput *input;
/**
 layer
 */
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;



//=============================子类实现方法==========================//
/**
 创建会话
 
 @param error error
 @return      返回YES代表成功，NO代表失败
 */
- (BOOL)creatSession:(NSError **)error;


//=============================基本方法==========================//
/**
 开启会话
 */
- (void)startSession;
/**
 关闭会话
 */
- (void)stopSession;
/**
 是否可以改变摄像头
 
 @return YES or NO
 */
- (BOOL)shouldChangeCamera;
/**
 切换摄像头
 
 @return 成功返回YES，失败返回NO
 */
- (BOOL)changeCamera;
/**
 是否能够对焦
 
 @return YES or NO
 */
- (BOOL)shouldFocus;
/**
 点击对焦
 
 @param point 坐标
 */
- (void)focusAtPoint:(CGPoint)point;
/**
 是否能够曝光
 
 @return YES or NO
 */
- (BOOL)shouldExpose;
/**
 点击曝光
 
 @param point point description
 */
- (void)exposeAtPoint:(CGPoint)point;
/**
 重置焦点和曝光
 */
- (void)resetFocusAndExposure;
/**
 是否支持闪光
 
 @return YES or NO
 */
- (BOOL)shouldFlash;
/**
 设置闪光模式
 
 @param flashModel flashModel description
 */
- (void)setFlashModel:(AVCaptureFlashMode)flashModel;
/**
 是否支持手电
 
 @return return value description
 */
- (BOOL)shouldTorch;
/**
 设置手电模式
 
 @param torchModel torchModel description
 */
- (void)setTorchModel:(AVCaptureTorchMode)torchModel;
@end
