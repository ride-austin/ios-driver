//
//  XLFormRowDescriptor+factory.h
//  Ride
//
//  Created by Theodore Gonzalez on 5/18/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <XLForm/XLForm.h>

@class TextFieldModel;
@class DatePickerModel;
@interface XLFormRowDescriptor (factory)
+(instancetype _Nonnull)rowTextFieldWithTag:(NSString *_Nonnull)rowTag
                                      title:(NSString *_Nullable)title
                                      value:(id _Nullable)value
                                placeholder:(id _Nullable)placeholder
                                    rowType:(NSString *_Nonnull)rowType
                                      model:(TextFieldModel *_Nullable)textFieldModel
                             requireMessage:(NSString *_Nullable)requireMsg
                          andValidatorArray:(NSArray<id<XLFormValidatorProtocol>> *_Nullable)arrayValidator;
+(instancetype _Nonnull)rowDatePickerWithTag:(NSString *_Nonnull)rowTag
                                       title:(NSString *_Nullable)title
                                       value:(id _Nullable)value
                                 placeholder:(id _Nullable)placeholder
                                     rowType:(NSString *_Nonnull)rowType
                                       model:(DatePickerModel *_Nonnull)datePickerModel
                              requireMessage:(NSString *_Nullable)requireMsg;
+(instancetype _Nonnull)rowImagePickerWithTag:(NSString *_Nonnull)rowTag
                                        title:(NSString *_Nullable)title
                                      rowType:(NSString *_Nonnull)rowType
                               requireMessage:(NSString *_Nullable)requireMsg;
+(instancetype _Nonnull)rowButtonWithTitleAndTag:(NSString *_Nonnull)rowTag
                                         rowType:(NSString *_Nonnull)rowType
                                        selector:(SEL _Nonnull )selector;
+(instancetype _Nonnull)rowBooleanPickerWithTag:(NSString *_Nonnull)rowTag
                                          title:(NSString *_Nullable)title
                                          value:(id _Nullable)value
                                    placeholder:(id _Nullable)placeholder
                                        rowType:(NSString *_Nonnull)rowType
                                 requireMessage:(NSString *_Nullable)requireMsg;

@end
