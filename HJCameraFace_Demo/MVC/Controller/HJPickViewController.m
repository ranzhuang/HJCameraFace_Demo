//
//  HJPickViewController.m
//  HJCamera_Demo
//
//  Created by MDLK-HJ on 2018/4/13.
//  Copyright © 2018年 MDLK-HJ. All rights reserved.
//

#import "HJPickViewController.h"
#import "HJCameraTakingPicture.h"


#define HJMacroWidth [UIScreen mainScreen].bounds.size.width
#define HJMacroHeight [UIScreen mainScreen].bounds.size.height
#define WS(weakSelf) __weak typeof(self) weakSelf = self;



@interface HJPickViewController ()

/// 返回
@property (weak, nonatomic) IBOutlet UIButton *backButton;
/// 改变摄像头
@property (weak, nonatomic) IBOutlet UIButton *changeCameraButton;
/// 开始按钮
@property (weak, nonatomic) IBOutlet UIButton *sureButton;

@property (nonatomic, strong) HJCameraTakingPicture *cameraTool;

@property (nonatomic, strong) UIImage *image;

@end

@implementation HJPickViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self createCamera];
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.hidden = YES;
}
- (void)viewWillDisappear:(BOOL)animated {
    self.navigationController.navigationBar.hidden = NO;
}

- (void)createCamera {
    self.cameraTool = [[HJCameraTakingPicture alloc] init];
    NSError *error;
    if([self.cameraTool creatSession:&error]) {
        [self.view.layer insertSublayer:self.cameraTool.previewLayer atIndex:0];
        [self.cameraTool startSession];
    }
}

#pragma mark - 点击事件

- (IBAction)backButtonDidClicked:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)changeButtonDidClicked:(UIButton *)sender {
    if (self.cameraTool.shouldChangeCamera) {
        [self.cameraTool changeCamera];
    }
}
- (IBAction)sureButtonDidClicked:(UIButton *)sender {
    WS(weakSelf)
    [self.cameraTool getStillImage:^(UIImage *image) {
        weakSelf.image = image;
        [weakSelf.cameraTool stopSession];
        [weakSelf backButtonDidClicked:nil];
    }];
}



@end
