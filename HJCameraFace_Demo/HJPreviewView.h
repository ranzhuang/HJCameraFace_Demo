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
@property (nonatomic, copy) NSArray *faces;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoLayer;

@end
