//
//  HJQrMainView.h
//  HJCameraFace_Demo
//
//  Created by MDLK-HJ on 2018/4/20.
//  Copyright © 2018年 黄炬. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HJQrMainView : UIView

/**
 必须调用此方法用来停止动画,否则动画会一直添加
 */
@property (nonatomic, assign)BOOL stop;

- (void)startAnimation;

@end
