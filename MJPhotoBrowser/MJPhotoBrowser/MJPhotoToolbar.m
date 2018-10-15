//
//  MJPhotoToolbar.m
//  FingerNews
//
//  Created by mj on 13-9-24.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "MJPhotoToolbar.h"
#import "MJPhoto.h"
#import <Photos/PHPhotoLibrary.h>

@interface MJPhotoToolbar()
{
    // 显示页码
    UILabel *_indexLabel;
    UIButton *_saveImageBtn;
}
@end

@implementation MJPhotoToolbar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setPhotos:(NSArray *)photos
{
    _photos = photos;
    
    if (_photos.count > 1) {
        _indexLabel = [[UILabel alloc] init];
        _indexLabel.font = [UIFont boldSystemFontOfSize:20];
        _indexLabel.frame = self.bounds;
        _indexLabel.backgroundColor = [UIColor clearColor];
        _indexLabel.textColor = [UIColor whiteColor];
        _indexLabel.textAlignment = NSTextAlignmentCenter;
        _indexLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:_indexLabel];
    }
    
    // 保存图片按钮
    CGFloat btnWidth = 24;//self.bounds.size.height;
    _saveImageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    _saveImageBtn.frame = CGRectMake(0, 0, btnWidth, btnWidth);
    _saveImageBtn.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
   
    //静态库
    if([UIImage imageNamed:@"MJPhotoBrowser.bundle/save_icon.png"]) {
        [_saveImageBtn setImage:[UIImage imageNamed:@"MJPhotoBrowser.bundle/save_icon.png"] forState:UIControlStateNormal];
        [_saveImageBtn setImage:[UIImage imageNamed:@"MJPhotoBrowser.bundle/save_icon_highlighted.png"] forState:UIControlStateHighlighted];
    }else {
        //动态库
        NSBundle *bundle = [NSBundle bundleForClass:self.class];
        UIImage *image = [UIImage imageNamed:@"MJPhotoBrowser.bundle/save_icon.png" inBundle:bundle compatibleWithTraitCollection:nil];
        UIImage *highlighted = [UIImage imageNamed:@"MJPhotoBrowser.bundle/save_icon_highlighted.png" inBundle:bundle compatibleWithTraitCollection:nil];
        [_saveImageBtn setImage:image forState:UIControlStateNormal];
        [_saveImageBtn setImage:highlighted forState:UIControlStateHighlighted];
    }
    
    [_saveImageBtn addTarget:self action:@selector(saveImage) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_saveImageBtn];
}

- (void)saveImage
{
    if (@available(iOS 11.0, *)) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusNotDetermined || status == PHAuthorizationStatusAuthorized) {
                //保存图片到相册
                [self realSave];
            } else {
                //====没有权限====
                [self showNoAlbumAuthalertControllerWithVC];
            }
        }];
    } else {
        //======判断 访问相册 权限是否开启=======
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        //有被授权访问的照片数据   用户已经明确否认了这一照片数据的应用程序访问
        //家长控制,不允许访问 || 用户拒绝当前应用访问相册
        if (status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied) {
            //====没有权限====
            [self showNoAlbumAuthalertControllerWithVC];
        } else {    //====有访问相册的权限=======
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {   //相册可用
                //因为需要知道该操作的完成情况，即保存成功与否，所以此处需要一个回调方法image:didFinishSavingWithError:contextInfo:
                [self realSave];
            } else {  // 相册不可用
                [SVProgressHUD showInfoWithStatus:@"保存失败"];
                [SVProgressHUD dismissWithDelay:1.0f];
                NSLog(@"相册不可用");
            }
        }
    }
}
- (void)showNoAlbumAuthalertControllerWithVC
{
    NSString *title;
    NSString *message;
    title = @"开启相册权限";
    message = @"开启后才能访问你的相册";
    __weak typeof(self) weakSelf = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
    }];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"去开启" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        //===无权限 引导去开启===
        if(weakSelf)
            [weakSelf openJurisdiction];
    }];
    [alertController addAction:cancel];
    [alertController addAction:ok];
    if(self.viewController){
        [self.viewController presentViewController:alertController animated:YES completion:nil];
    }else{
        [SVProgressHUD showInfoWithStatus:@"开启后才能访问你的相册"];
        [SVProgressHUD dismissWithDelay:1.0f];
    }
    
}



#pragma mark-------去设置界面开启权限----------
- (void)openJurisdiction
{
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    //CGFloat version= [[UIDevice currentDevice].systemVersion floatValue];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
         if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        } else {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

-(void)realSave {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        MJPhoto *photo =self->_photos[self->_currentPhotoIndex];
        UIImageWriteToSavedPhotosAlbum(photo.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    });
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        [SVProgressHUD showInfoWithStatus:@"保存失败"];
        [SVProgressHUD dismissWithDelay:1.0f];
    } else {
        MJPhoto *photo = _photos[_currentPhotoIndex];
        photo.save = YES;
        _saveImageBtn.enabled = NO;
        [SVProgressHUD showSuccessWithStatus:@"成功保存到相册"];
        [SVProgressHUD dismissWithDelay:1.0f];
    }
}

- (void)setCurrentPhotoIndex:(NSUInteger)currentPhotoIndex
{
    if(_photos.count >currentPhotoIndex){
        _currentPhotoIndex = currentPhotoIndex;
        // 更新页码
        _indexLabel.text = [NSString stringWithFormat:@"%d / %d", (int)_currentPhotoIndex + 1, (int)_photos.count];
    
        MJPhoto *photo = _photos[_currentPhotoIndex];
        // 按钮
        _saveImageBtn.enabled = photo.image != nil && !photo.save;
        _saveImageBtn.hidden =!_showSaveBtn;
    }
   
}

@end
