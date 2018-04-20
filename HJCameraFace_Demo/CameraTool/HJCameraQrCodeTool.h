//
//  HJCameraQrCodeTool.h
//  HJCamera_Demo
//
//  Created by MDLK-HJ on 2018/4/20.
//  Copyright © 2018年 MDLK-HJ. All rights reserved.
//

#import "HJCameraBaseTool.h"

@protocol HJCameraQrCodeToolDelegate <NSObject>

/**
 已经获取到结果

 @param str 字符串
 */
- (void)cameraQrcodeDidGetResultWithString:(NSString *)str;

@end

@interface HJCameraQrCodeTool : HJCameraBaseTool

@property (nonatomic, weak)id <HJCameraQrCodeToolDelegate> delegate;

@end
