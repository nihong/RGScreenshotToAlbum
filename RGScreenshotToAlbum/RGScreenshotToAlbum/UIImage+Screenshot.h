//
//  UIImage+Screenshot.h
//  Vmei
//
//  Created by ios-02 on 2018/3/6.
//  Copyright © 2018年 com.vmei. All rights reserved.
//


#import <UIKit/UIKit.h>

typedef void(^RGCompleteBlock)(BOOL success);

@interface UIImage (Screenshot)


/**
 保存图片到自定义相册，并在主线程回调

 @param complete 回调
 */
-(void)saveImgToCustomPhotoAssetWithHandle:(RGCompleteBlock)complete;


//@property(nonatomic,copy)RGCompleteBlock complete;
@end
