//
//  HJQrMainView.m
//  HJCameraFace_Demo
//
//  Created by MDLK-HJ on 2018/4/20.
//  Copyright © 2018年 黄炬. All rights reserved.
//

#import "HJQrMainView.h"

@interface HJQrMainView();

/**
 扫码框
 */
@property (nonatomic, strong) UIImageView *qrBoxImageView;

/**
 扫码条
 */
@property (nonatomic, strong) UIImageView *qrLineImageView;

@end

@implementation HJQrMainView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setUI];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setUI];
    }
    return self;
}

- (void)setUI {
    [self creatViewWithFrame:CGRectMake(0, 0, HJScreenWidth, HJQrY)];
    [self creatViewWithFrame:CGRectMake(0, HJQrY, HJQrX, HJQrWidth)];
    [self creatViewWithFrame:CGRectMake(HJScreenWidth - HJQrX, HJQrY, HJQrX, HJQrWidth)];
    [self creatViewWithFrame:CGRectMake(0, HJQrY + HJQrWidth, HJScreenWidth, HJScreenHeight - (HJQrY + HJQrWidth))];
    [self addSubview:self.qrBoxImageView];
    [self addSubview:self.qrLineImageView];
    [self startAnimation];
    
}

#pragma mark - 创建上下左右视图
- (void)creatViewWithFrame:(CGRect)frame {
    UIView *tempView = [[UIView alloc] initWithFrame:frame];
    tempView.backgroundColor = [[UIColor alloc] initWithRed:0 green:0 blue:0 alpha:0.5];
    [self addSubview:tempView];
}

#pragma mark - 动画
- (void)startAnimation {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    animation.duration = 2.5;
    animation.fromValue = 0;
    animation.toValue = @(HJQrWidth);
    animation.repeatCount = 1000;
    animation.removedOnCompletion = NO;
    [self.qrLineImageView.layer addAnimation:animation forKey:@"translationY"];
}

- (void)stopAnimation {
    [self.qrLineImageView.layer removeAnimationForKey:@"translationY"];
}

#pragma mark - get
- (UIImageView *)qrBoxImageView {
    if (!_qrBoxImageView) {
        UIImage *image = [[UIImage imageNamed:@"二维码框"] tensileImage];
        _qrBoxImageView = [[UIImageView alloc] initWithFrame:CGRectMake(HJQrX, HJQrY, HJQrWidth, HJQrWidth)];
        _qrBoxImageView.image = image;
    }
    return _qrBoxImageView;
}

- (UIImageView *)qrLineImageView {
    if (!_qrLineImageView) {
        _qrLineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(HJQrX, HJQrY, HJQrWidth, 4)];
        _qrLineImageView.image = [UIImage imageNamed:@"扫描条"];
    }
    return _qrLineImageView;
}

@end
