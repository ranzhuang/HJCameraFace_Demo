//
//  HJCameraTakingFace.h
//  HJCameraFace_Demo
//
//  Created by MDLK-HJ on 2018/4/23.
//  Copyright © 2018年 黄炬. All rights reserved.
//

#import "HJCameraBaseTool.h"
@protocol HJCameraTakingFaceDelegate <NSObject>


/**
 已经捕捉到数据

 @param metadataObjects metadataObjects
 */
- (void)cameraDidOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects;

@end
@interface HJCameraTakingFace : HJCameraBaseTool

@property (nonatomic, weak)id <HJCameraTakingFaceDelegate> delegate;
@end
