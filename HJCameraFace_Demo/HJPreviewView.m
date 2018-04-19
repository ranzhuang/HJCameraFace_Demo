//
//  HJPreviewView.m
//  HJCameraFace_Demo
//
//  Created by 黄炬 on 2018/4/18.
//  Copyright © 2018年 黄炬. All rights reserved.
//

#import "HJPreviewView.h"


@interface  HJPreviewView()

@property (nonatomic, strong) NSMutableArray *faceLayers;

@end

@implementation HJPreviewView

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

#pragma mark - 设置UI
- (void)setUI {
    self.faceLayers = [NSMutableArray array];
}

/**
 将设备坐标空间的人脸对象转换为视图空间对象集合

 @param facesArray facesArray description
 @return return value description
 */
- (NSArray *)transformFacesFormFaces:(NSArray *)facesArray withLayer:(AVCaptureVideoPreviewLayer *)videoLayer {
    NSMutableArray *transfrtmFaces = [NSMutableArray array];
    for (AVMetadataObject *faces in facesArray) {
        if (faces.type == AVMetadataObjectTypeFace) {
            AVMetadataObject *transformFace = [videoLayer transformedMetadataObjectForMetadataObject:faces];
            if (transformFace) {
                [transfrtmFaces addObject:transformFace];
            }
        }
    }
    return transfrtmFaces;
}

- (CATransform3D)orientationTransform {
    CGFloat angle = 0.0;
    switch ([UIDevice currentDevice].orientation) {
        case UIDeviceOrientationPortraitUpsideDown:
            angle = M_PI;
            break;
        case UIDeviceOrientationLandscapeRight:
            angle = -M_PI / 2.0f;
            break;
        case UIDeviceOrientationLandscapeLeft:
            angle = M_PI / 2.0f;
            break;
            
        default:
            angle = 0.0;
            break;
    }
    return CATransform3DMakeRotation(angle, 0, 0, 1);
}

- (void)showPreviewWithFaces:(NSArray *)faces withVideoLayer:(AVCaptureVideoPreviewLayer *)videoLayer {
    //便利videoLayer的sublayers,如果是之前我们存入的layer，就将其移除
    for (CALayer *layer in videoLayer.sublayers) {
        if ([self.faceLayers containsObject:layer]) {
            [layer removeFromSuperlayer];
            [self.faceLayers removeObject:layer];
        }
    }
    NSArray *transformFaces = [self transformFacesFormFaces:faces withLayer:videoLayer];
    //将识别到的face添加上识别框
    for (AVMetadataFaceObject *face in transformFaces) {
        CALayer *layer = [CALayer layer];
        layer.borderWidth = 5.0f;
        layer.borderColor = [UIColor colorWithRed:0.188 green:0.517 blue:0.877 alpha:1].CGColor;
        layer.transform = CATransform3DIdentity;
        layer.frame = face.bounds;
        // 斜倾角
        if ([face hasRollAngle]) {
            CATransform3D t = CATransform3DMakeRotation(face.rollAngle * M_PI / 180, 0, 0, 1);
            layer.transform = CATransform3DConcat(layer.transform, t);
        }

        if ([face hasYawAngle]) {
            CATransform3D t = CATransform3DConcat(CATransform3DMakeRotation(face.yawAngle * M_PI / 180, 0, -1, 0), [self orientationTransform]);

            layer.transform = CATransform3DConcat(layer.transform, t);
        }
        [videoLayer addSublayer:layer];
        //将所创建的layer存入数组中
        [self.faceLayers addObject:layer];
    }
}
@end
