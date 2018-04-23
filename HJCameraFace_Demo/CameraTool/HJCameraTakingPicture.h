//
//  HJCameraTakingPicture.h
//  HJCameraForImageDemo
//
//  Created by 黄炬 on 2018/4/9.
//  Copyright © 2018年 黄炬. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "HJCameraBaseTool.h"




/**
 传图片的Block
 
 @param image image
 */
typedef void(^successBlock)(UIImage *image);

@interface HJCameraTakingPicture :  HJCameraBaseTool


/**
 捕捉静态图片
 
 @param successCallback 成功回调返回一张图片
 */
- (void)getStillImage:(successBlock)successCallback;
/**
 保存图片到相册
 
 @param image image description
 */
- (void)savaToLiraryWithImage:(UIImage *)image success:(successBlock)successCallback error:(errorBlock)errorCallback;


@end
