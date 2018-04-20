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

/**
 错误信息的Block

 @param error 错误信息
 */
typedef void(^errorBlock)(NSError *error);

/**
 结束录制视频的block

 @param outputFileURL outputFileURL description
 @param error error description
 */
typedef void(^didFinishRecordingMovie)(NSURL *outputFileURL, NSError *error);

@interface HJCameraTakingPicture :  HJCameraBaseTool
//=============================基本属性==========================//







//=============================图片相关==========================//

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


//=============================视频相关==========================//
/**
 是否能记录
 
 @return YES or NO
 */
- (BOOL)isRecording;
/**
 开始记录
 */
- (void)startRecording;
/**
 停止记录
 */
- (void)stopRecording;
/**
 将视频写入相册
 
 @param videoUrl videoUrl description
 */
- (void)writeMovieToLibrary:(NSURL *)videoUrl success:(void(^)(NSString *videoPath))successCallback error:(errorBlock)errorCallback;
/**
 录制视频结束的回调
 */
@property (nonatomic, copy) didFinishRecordingMovie finishRecord;

@end
