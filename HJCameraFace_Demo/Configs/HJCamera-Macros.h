//
//  HJCamera-Macros.h
//  HJCameraFace_Demo
//
//  Created by MDLK-HJ on 2018/4/20.
//  Copyright © 2018年 黄炬. All rights reserved.
//

#ifndef HJCamera_Macros_h
#define HJCamera_Macros_h

#define HJScreenWidth ([UIScreen mainScreen].bounds.size.width)
#define HJScreenHeight ([UIScreen mainScreen].bounds.size.height)
#define HJQrX (50)
#define HJQrWidth (HJScreenWidth - HJQrX * 2)
#define HJQrY ((HJScreenHeight - (HJQrWidth)) / 2)



//Block

/**
 错误信息的Block
 
 @param error 错误信息
 */
typedef void(^errorBlock)(NSError *error);
#endif /* HJCamera_Macros_h */
