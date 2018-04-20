//
//  ViewController.m
//  HJCameraFace_Demo
//
//  Created by 黄炬 on 2018/4/18.
//  Copyright © 2018年 黄炬. All rights reserved.
//

#import "ViewController.h"
#import <objc/objc.h>

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *contentView;
@property (nonatomic, strong) NSMutableDictionary *controlDict;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.contentView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.controlDict.allKeys.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = self.controlDict.allValues[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Class tempClass = NSClassFromString(self.controlDict.allKeys[indexPath.row]);
    [self.navigationController pushViewController:[tempClass new] animated:YES];
    
}

- (UITableView *)contentView {
    if (!_contentView) {
        _contentView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, HJScreenWidth, HJScreenHeight) style:UITableViewStylePlain];
        _contentView.delegate = self;
        _contentView.dataSource = self;
//        _contentView.rowHeight = UITableViewAutomaticDimension;
//        _contentView.estimatedRowHeight = 80;
    }
    return _contentView;
}

- (NSMutableDictionary *)controlDict {
    if (!_controlDict) {
        _controlDict = @{@"HJPickViewController":@"自定义相机", @"HJQrCodeViewController":@"二维码扫描", @"HJFaceViewController":@"人脸识别"}.mutableCopy;
    }
    return _controlDict;
}

@end
