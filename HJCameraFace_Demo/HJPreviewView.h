//
//  HJPreviewView.h
//  HJCameraFace_Demo
//
//  Created by 黄炬 on 2018/4/18.
//  Copyright © 2018年 黄炬. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface HJPreviewView : UIView


/**
 显示人脸识别框

 @param faces      获取到的人脸对象数组
 @param videoLayer 图层
 */
- (void)showPreviewWithFaces:(NSArray *)faces withVideoLayer:(AVCaptureVideoPreviewLayer *)videoLayer;

@end
