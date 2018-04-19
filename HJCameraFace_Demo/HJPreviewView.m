//
//  HJPreviewView.m
//  HJCameraFace_Demo
//
//  Created by 黄炬 on 2018/4/18.
//  Copyright © 2018年 黄炬. All rights reserved.
//

#import "HJPreviewView.h"


/**
 视角转换

 @param eyePosition eyePosition description
 @return return value description
 */
static inline CATransform3D HJMakePerspectiveTransform(CGFloat eyePosition) {
    CATransform3D transform = CATransform3DIdentity;
    //眼睛的位置
    transform.m34 = -1.0;
    return transform;
}

@interface  HJPreviewView()

@property (nonatomic, strong) CALayer *overlayLayer;
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
//    self.videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
//    self.overlayLayer = [CALayer layer];
//    self.overlayLayer.frame = self.bounds;
//    self.overlayLayer.sublayerTransform = HJMakePerspectiveTransform(1000);
//    [self.videoLayer addSublayer:self.overlayLayer];
}

/**
 将设备坐标空间的人脸对象转换为视图空间对象集合

 @param facesArray facesArray description
 @return return value description
 */
- (NSArray *)transformFacesFormFaces:(NSArray *)facesArray {
    NSMutableArray *transfrtmFaces = [NSMutableArray array];
    for (AVMetadataObject *faces in facesArray) {
        if (faces.type == AVMetadataObjectTypeFace) {
            AVMetadataObject *transformFace = [self.videoLayer transformedMetadataObjectForMetadataObject:faces];
            [transfrtmFaces addObject:transformFace];
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

#pragma mark - set & get

- (void)setFaces:(NSArray *)faces {
    _faces = faces;
    for (CALayer *layer in self.videoLayer.sublayers) {
        if ([self.faceLayers containsObject:layer]) {
            [layer removeFromSuperlayer];
            [self.faceLayers removeObject:layer];
        }
    }
    NSArray *transformFaces = [self transformFacesFormFaces:faces];
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
        [self.videoLayer addSublayer:layer];
        [self.faceLayers addObject:layer];
    }
//    for (NSNumber *faceID in keyFaces) {
//        CALayer *layer = self.faceLayers[faceID];
//        [layer removeFromSuperlayer];
//        [self.faceLayers removeObjectForKey:faceID];
//    }
}
@end
