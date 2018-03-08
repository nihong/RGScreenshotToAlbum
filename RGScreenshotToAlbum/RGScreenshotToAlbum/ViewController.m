//
//  ViewController.m
//  RGScreenshotToAlbum
//
//  Created by ios-02 on 2018/3/8.
//  Copyright © 2018年 Hello Kitty. All rights reserved.
//

#import "ViewController.h"
#import "UIImage+Screenshot.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIImageView *demo = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"WechatIMG205"]];
    demo.frame = self.view.bounds;
    [self.view addSubview:demo];
    
    UIButton *downloadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [downloadBtn setTitle:@"Download" forState:UIControlStateNormal];
    downloadBtn.frame = CGRectMake(0, 0, 100.f, 44.f);
    downloadBtn.center = self.view.center;
    [downloadBtn addTarget:self action:@selector(downloadBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:downloadBtn];
}

-(void)downloadBtnClicked{
    UIImage *image = nil;
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, YES, 0);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    if (image) {
        [image saveImgToCustomPhotoAssetWithHandle:^(BOOL success) {
            NSLog(@"保存成功");
        }];
    }
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
