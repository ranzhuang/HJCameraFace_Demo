//
//  HJCameraTakingMovie.h
//  HJCameraFace_Demo
//
//  Created by MDLK-HJ on 2018/4/23.
//  Copyright © 2018年 黄炬. All rights reserved.
//

#import "HJCameraBaseTool.h"
/**
 结束录制视频的block
 
 @param outputFileURL outputFileURL description
 @param error error description
 */
typedef void(^didFinishRecordingMovie)(NSURL *outputFileURL, NSError *error);
@interface HJCameraTakingMovie : HJCameraBaseTool

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
