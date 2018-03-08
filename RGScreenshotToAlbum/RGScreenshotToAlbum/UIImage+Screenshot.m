//
//  UIImage+Screenshot.m
//  Vmei
//
//  Created by ios-02 on 2018/3/6.
//  Copyright © 2018年 com.vmei. All rights reserved.
//

#import "UIImage+Screenshot.h"
#import <Photos/Photos.h>
#import <objc/runtime.h>

#define kPhotoAssetName @"唯美美妆"
static void *completeKey = &completeKey;

@interface UIImage ()


@property(nonatomic,copy)RGCompleteBlock complete;

@end


@implementation UIImage (Screenshot)

-(void)setComplete:(RGCompleteBlock)complete
{
    objc_setAssociatedObject(self, &completeKey, complete, OBJC_ASSOCIATION_COPY);
}

-(RGCompleteBlock)complete
{
    return objc_getAssociatedObject(self, &completeKey);
}

/**
 本地保存
 */
-(void)saveImgToCustomPhotoAssetWithHandle:(RGCompleteBlock)complete;
{
    self.complete = complete;
    if (!self){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.complete) {
                self.complete(NO);
            }
        });
        
        return;
    }
    
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    
    if (status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied) {
        
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication]canOpenURL:url]) {
            [[UIApplication sharedApplication]openURL:url options:@{UIApplicationOpenURLOptionUniversalLinksOnly : @YES} completionHandler:^(BOOL success) {
                
            }];

        }
        
    }else if(status == PHAuthorizationStatusNotDetermined){
        
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            
            if (status == PHAuthorizationStatusAuthorized) {
                
                [self saveImage:self];
            }else{
                
            }
        }];
    }else if(status == PHAuthorizationStatusAuthorized){
        [self saveImage:self];
        
    }
    
    
}




//保存图片
-(void)saveImage:(UIImage *)image{
    
    
    __block  NSString *assetLocalIdentifier;
    [[PHPhotoLibrary sharedPhotoLibrary]performChanges:^{
        
        //1.保存图片到相机胶卷中----创建图片的请求
        assetLocalIdentifier = [PHAssetCreationRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if(success == NO){
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.complete) {
                    self.complete(NO);
                }
            });
//            NSLog(@"保存图片失败----(创建图片的请求)");
            return ;
        }
        
        // 2.获得相簿
        PHAssetCollection *createdAssetCollection = [self createAssetCollection];
        if (createdAssetCollection == nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
//                self.complete(NO);
                if (self.complete) {
                    self.complete(NO);
                }
            });
//            NSLog(@"保存图片成功----(创建相簿失败!)");
            return;
        }
        
        // 3.将刚刚添加到"相机胶卷"中的图片到"自己创建相簿"中
        [[PHPhotoLibrary sharedPhotoLibrary]performChanges:^{
            
            //获得图片
            PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[assetLocalIdentifier] options:nil].lastObject;
            //添加图片到相簿中的请求
            PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:createdAssetCollection];
            // 添加图片到相簿
            [request addAssets:@[asset]];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.complete) {
                    self.complete(success);
                }
                
            });
            
        }];
    }];
}


//  获得相簿
-(PHAssetCollection *)createAssetCollection{
    
    //判断是否已存在
    PHFetchResult<PHAssetCollection *> *assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection * assetCollection in assetCollections) {
        if ([assetCollection.localizedTitle isEqualToString:kPhotoAssetName]) {
            //说明已经有哪对象了
            return assetCollection;
        }
    }
    
    //创建新的相簿
    __block NSString *assetCollectionLocalIdentifier = nil;
    NSError *error = nil;
    //同步方法
    [[PHPhotoLibrary sharedPhotoLibrary]performChangesAndWait:^{
        // 创建相簿的请求
        assetCollectionLocalIdentifier = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:kPhotoAssetName].placeholderForCreatedAssetCollection.localIdentifier;
    } error:&error];
    
    if (error){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.complete) {
                self.complete(NO);
            }
        });
        return nil;
    }
    
    return [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[assetCollectionLocalIdentifier] options:nil].lastObject;
}

@end
