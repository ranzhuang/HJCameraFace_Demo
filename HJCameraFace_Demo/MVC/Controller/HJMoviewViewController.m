//
//  HJPickViewController.m
//  HJCamera_Demo
//
//  Created by MDLK-HJ on 2018/4/13.
//  Copyright © 2018年 MDLK-HJ. All rights reserved.
//

#import "HJMoviewViewController.h"
#import "HJCameraTakingMovie.h"


#define HJMacroWidth [UIScreen mainScreen].bounds.size.width
#define HJMacroHeight [UIScreen mainScreen].bounds.size.height
#define WS(weakSelf) __weak typeof(self) weakSelf = self;



@interface HJMoviewViewController ()

/// 返回
@property (weak, nonatomic) IBOutlet UIButton *backButton;
/// 改变摄像头
@property (weak, nonatomic) IBOutlet UIButton *changeCameraButton;
/// 开始按钮
@property (weak, nonatomic) IBOutlet UIButton *sureButton;

@property (nonatomic, strong) HJCameraTakingMovie *cameraTool;

@end

@implementation HJMoviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
}

- (void)viewWillAppear:(BOOL)animated {
    [self createCamera];
    self.navigationController.navigationBar.hidden = YES;
}
- (void)viewWillDisappear:(BOOL)animated {
    self.navigationController.navigationBar.hidden = NO;
}

- (void)createCamera {
    self.cameraTool = [[HJCameraTakingMovie alloc] init];
    NSError *error;
    if([self.cameraTool creatSession:&error]) {
        [self.view.layer insertSublayer:self.cameraTool.previewLayer atIndex:0];
        [self.cameraTool startSession];
    }
    WS(weakSelf);
    self.cameraTool.finishRecord = ^(NSURL *outputFileURL, NSError *error) {
        [weakSelf.cameraTool writeMovieToLibrary:outputFileURL success:^(NSString *videoPath) {
            NSLog(@"保存成功");
        } error:^(NSError *error) {
            NSLog(@"保存失败");
        }];
    };
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
    if ([sender.currentTitle isEqualToString:@"开始录制"]) {
        [self.cameraTool startRecording];
        [sender setTitle:@"录制中" forState:UIControlStateNormal];
    } else if ([sender.currentTitle isEqualToString:@"录制中"]) {
        [self.cameraTool stopRecording];
        [self.cameraTool stopSession];
        [sender.currentTitle isEqualToString:@"录制完成"];
    }
}



@end
