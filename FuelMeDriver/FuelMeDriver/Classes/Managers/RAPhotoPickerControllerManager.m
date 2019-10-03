//
//  RAPhotoPickerControllerManager.m
//  RideAustin
//
//  Created by Kitos on 3/10/16.
//  Copyright © 2016 Crossover Markets Inc. All rights reserved.
//

#import "RAPhotoPickerControllerManager.h"

#import <AVFoundation/AVFoundation.h>
#import <Photos/PHPhotoLibrary.h>

#import "NSObject+className.h"

#define kErrorTitleCamera    @"Camera Permission Denied"
#define kErrorTitleLibrary   @"Media Library Permission Denied"
#define kErrorMessageCamera  @"You have to grant camera access permission on settings to continue."
#define kErrorMessageLibrary @"You have to grant media library access permission on settings to continue."

@interface RAPhotoPickerControllerManager ()

@property (nonatomic,copy) RAPhotoPickerFinishedBlock finishedBlock;
@property (nonatomic,copy) RAPhotoPickerCancelledBlock cancelledBlock;
@property (nonatomic,copy) RAPhotoPickerAccessDeniedBlock accessDeniedHandler;

@end

@interface RAPhotoPickerControllerManager (ImagePickerDelegate)<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@end

@implementation RAPhotoPickerControllerManager

+ (RAPhotoPickerControllerManager *)pickerManager {
    return [RAPhotoPickerControllerManager new];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)dealloc {
    DBLog(@"deallocated %@",[self className]);
}

- (void)checkCameraPermissions:(RAPhotoPermissionBlock)block {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    switch (authStatus) {
        case AVAuthorizationStatusAuthorized:
            if (block) {
                block(YES);
            }
            break;
            
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
        case AVAuthorizationStatusNotDetermined: {
            //to avoid crash on iOS < 7.0 versions
            if ([AVCaptureDevice respondsToSelector:@selector(requestAccessForMediaType: completionHandler:)]) {
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                    //permission granted
                    if (granted) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (block) {
                                block(YES);
                            }
                        });
                    } else {
                        // permission denied
                        if (block) {
                            block(NO);
                        }
                    }
                }];
            } else {
                //iOS <= 6 is safe
                if (block) {
                    block(YES);
                }
            }
            break;
        }
        default:
            block(NO);
            break;
    }
}

- (void)checkPhotoLibraryPermissions:(RAPhotoPermissionBlock)block {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    
    switch (status) {
        case PHAuthorizationStatusAuthorized:
            if (block) {
                block(YES);
            }
            break;
        case PHAuthorizationStatusDenied:
        case PHAuthorizationStatusRestricted:
        case PHAuthorizationStatusNotDetermined: {
            //to avoid crash on iOS < 8.0 versions
            if ([PHPhotoLibrary respondsToSelector:@selector(requestAuthorization:)]){
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus authorizationStatus) {
                    if (authorizationStatus == PHAuthorizationStatusAuthorized) {
                        // permission granted
                        if (block) {
                            block(YES);
                        }
                    } else {
                        // permission denied
                        if (block) {
                            block(NO);
                        }
                    }
                }];
            }
            
            break;
        }
        default:
            block(NO);
            break;
    }
}

- (void)showCameraFromViewController:(UIViewController *)viewController allowEditing:(BOOL)allow {
    __weak __typeof__(self) weakself = self;
    //check for camera permissions
    [self checkCameraPermissions:^(BOOL granted){
        if (granted) {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                picker.delegate = weakself;
                picker.allowsEditing = allow;
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [viewController presentViewController:picker animated:YES completion:NULL];
                });
            } else {
                NSError *error = [NSError errorWithDomain:@"com.rideaustin.error.camera.notAvailable" code:-1 userInfo:@{NSLocalizedFailureReasonErrorKey: @"Camera is not available in this device. Please check your settings."}];
                if (weakself.finishedBlock) {
                    weakself.finishedBlock(nil,error);
                }
                weakself.accessDeniedHandler = nil;
            }
        } else {
            if (weakself.accessDeniedHandler) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakself.accessDeniedHandler(kErrorTitleCamera, kErrorMessageCamera);
                });
            }
            weakself.finishedBlock = nil;
        }
        weakself.cancelledBlock = nil;
    }];
}

- (void)showLibraryFromViewController:(UIViewController *)viewController allowEditing:(BOOL)allow {
    __weak __typeof__(self) weakself = self;
    //check for camera permissions
    [self checkPhotoLibraryPermissions:^(BOOL granted){
        if (granted) {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                picker.delegate = weakself;
                picker.allowsEditing = allow;
                picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [viewController presentViewController:picker animated:YES completion:nil];
                });
            } else {
                NSError *error = [NSError errorWithDomain:@"com.rideaustin.error.photoLibrary.notAvailable" code:-2 userInfo:@{NSLocalizedFailureReasonErrorKey: @"Cannot access the photo library. Please check your settings."}];
                if (weakself.finishedBlock) {
                    weakself.finishedBlock(nil,error);
                }
                weakself.accessDeniedHandler = nil;
            }
        } else {
            if (weakself.accessDeniedHandler) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakself.accessDeniedHandler(kErrorTitleLibrary, kErrorMessageLibrary);
                });
            }
            weakself.finishedBlock  = nil;
        }
        weakself.cancelledBlock = nil;
    }];
}

- (void)showPickerControllerFromViewController:(UIViewController*)viewController
                                       sender:(UIView *)sender
                                 allowEditing:(BOOL)allow
                                finishedBlock:(RAPhotoPickerFinishedBlock)finishedHandler
                            accessDeniedBlock:(RAPhotoPickerAccessDeniedBlock)accessDeniedHandler {
    [self showPickerControllerFromViewController:viewController
                                          sender:sender
                                    allowEditing:allow
                                   finishedBlock:finishedHandler
                                  cancelledBlock:nil
                               accessDeniedBlock:accessDeniedHandler];
}

- (void)showPickerControllerFromViewController:(UIViewController*)viewController
                                       sender:(UIView *)sender
                                 allowEditing:(BOOL)allow
                                finishedBlock:(RAPhotoPickerFinishedBlock)finishedHandler
                               cancelledBlock:(RAPhotoPickerCancelledBlock)cancelledHandler
                            accessDeniedBlock:(RAPhotoPickerAccessDeniedBlock)accessDeniedHandler {
    
    self.finishedBlock = finishedHandler;
    self.cancelledBlock = cancelledHandler;
    self.accessDeniedHandler = accessDeniedHandler;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Source" message:@"From where do you want to take the picture?" preferredStyle:UIAlertControllerStyleActionSheet];
    alert.popoverPresentationController.sourceView = sender;
    alert.popoverPresentationController.sourceRect = sender.bounds;
    
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

        //FIX RA-7552 show camera with permission check
        [self showCameraFromViewController:viewController allowEditing:allow];
        
    }];

    UIAlertAction *libraryAction = [UIAlertAction actionWithTitle:@"Choose from library" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        //FIX RA-7552 show library with permission check
        [self showLibraryFromViewController:viewController allowEditing:allow];
    }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        self.finishedBlock       = nil;
        self.accessDeniedHandler = nil;
        if (self.cancelledBlock) {
            self.cancelledBlock();
        }
    }];
    
    [alert addAction:cameraAction];
    [alert addAction:libraryAction];
    [alert addAction:cancelAction];
    
    [viewController presentViewController:alert animated:YES completion:nil];
}

@end

#pragma mark ImagePicker Delegate

@implementation RAPhotoPickerControllerManager (ImagePickerDelegate)

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    UIImage *chosenImage = editedImage ? editedImage : originalImage;
    
    [picker dismissViewControllerAnimated:YES completion:^{
        if (self.finishedBlock) {
            self.finishedBlock(chosenImage,nil);
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
        if (self.cancelledBlock) {
            self.cancelledBlock();
        }
    }];
}

@end
