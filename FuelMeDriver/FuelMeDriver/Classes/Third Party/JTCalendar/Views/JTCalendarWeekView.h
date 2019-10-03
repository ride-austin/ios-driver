//
//  JTCalendarWeekView.h
//  JTCalendar
//
//  Created by Jonathan Tribouharet
//

#import <UIKit/UIKit.h>

#import "JTCalendarWeek.h"

@interface JTCalendarWeekView : UIView<JTCalendarWeek>

@property (nonatomic, weak) JTCalendarManager *manager;

@property (nonatomic, readonly) NSDate *startDate;

@property (nonatomic, readonly) UIView *circleView;

/*!
 * Must be call if override the class
 */
- (void)commonInit;

@end
