//
//  HMOneViewController.m
//  修改无限循环
//
//  Created by leo on 14-12-7.
//  Copyright (c) 2014年 itheima. All rights reserved.
//

#import "HMOneViewController.h"

@interface HMOneViewController ()

@end

@implementation HMOneViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeContactAdd];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    [btn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)dealloc
{
    

}

- (void)setImageModel:(HMImageModel *)imageModel
{
    _imageModel = imageModel;
    NSLog(@"<图片模型.imageName == %@> %s",self.imageModel.imageName , __FUNCTION__);
}

@end
