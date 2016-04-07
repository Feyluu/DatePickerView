//
//  DatePickerView.h
//  DLDatePicker
//
//  Created by 东方汇融 on 16/4/7.
//  Copyright © 2016年 cc.umoney. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DatePickerView;
@protocol DatePickerViewDelegate<NSObject>

@optional
-(void)datePickerViewConfirmAction:(DatePickerView *)pickerView selectedDate:(NSDate *)pickerDate;
@end

@interface DatePickerView : NSObject
@property (nonatomic,assign) id<DatePickerViewDelegate>delegate;
-(void)showView;
-(void)dismissView;
@end
