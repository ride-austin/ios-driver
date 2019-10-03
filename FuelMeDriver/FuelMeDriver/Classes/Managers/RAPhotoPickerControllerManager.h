//
//  RAPhotoPickerControllerManager.h
//  RideAustin
//
//  Created by Kitos on 3/10/16.
//  Copyright © 2016 Crossover Markets Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^RAPhotoPickerFinishedBlock)(UIImage * _Nullable image, NSError * _Nullable error);
typedef void(^RAPhotoPickerCancelledBlock)(void);
typedef void(^RAPhotoPermissionBlock)(BOOL granted);
typedef void(^RAPhotoPickerAccessDeniedBlock)(NSString  * _Nonnull errorTitle, NSString * _Nonnull errorMessage);

@interface RAPhotoPickerControllerManager : NSObject

+ (RAPhotoPickerControllerManager * _Nonnull)pickerManager;

- (void)showPickerControllerFromViewController:(UIViewController * _Nonnull)viewController
                                       sender:(UIView * _Nullable)sender
                                 allowEditing:(BOOL)allow
                                finishedBlock:(RAPhotoPickerFinishedBlock _Nullable)finishedHandler
                            accessDeniedBlock:(RAPhotoPickerAccessDeniedBlock _Nullable)accessDeniedHandler;

- (void)showPickerControllerFromViewController:(UIViewController * _Nonnull)viewController
                                       sender:(UIView * _Nullable)sender
                                 allowEditing:(BOOL)allow
                                finishedBlock:(RAPhotoPickerFinishedBlock _Nullable)finishedHandler
                               cancelledBlock:(RAPhotoPickerCancelledBlock _Nullable)cancelledHandler
                            accessDeniedBlock:(RAPhotoPickerAccessDeniedBlock _Nullable)accessDeniedHandler;

- (void)checkCameraPermissions:(RAPhotoPermissionBlock _Nullable)block;
- (void)checkPhotoLibraryPermissions:(RAPhotoPermissionBlock _Nullable)block;

@end
