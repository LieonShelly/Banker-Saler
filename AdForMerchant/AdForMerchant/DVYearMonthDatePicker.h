//
//  DVYearMonthDatePicker.h
//  DVYearMonthDatePicker
//
//  Created by Tzzzzz on 15/11/18.
//  Copyright © 2015年 Windward. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DVYearMonthDatePicker : UIPickerView<UIPickerViewDelegate, UIPickerViewDataSource>
@property (nonatomic, strong) UIColor *monthSelectedTextColor;
@property (nonatomic, strong) UIColor *monthTextColor;

@property (nonatomic, strong) UIColor *yearSelectedTextColor;
@property (nonatomic, strong) UIColor *yearTextColor;

@property (nonatomic, strong) UIFont *monthSelectedFont;
@property (nonatomic, strong) UIFont *monthFont;

@property (nonatomic, strong) UIFont *yearSelectedFont;
@property (nonatomic, strong) UIFont *yearFont;

@property (nonatomic, assign) NSInteger rowHeight;


/**
 *  查看datePicker当前选择的日期
 */
@property (nonatomic, strong, readonly) NSDate *date;

/**
 *  datePicker显示今天
 */
-(void)selectToday;

/**
 *  datePicker显示date
 */
- (void)selectDate:(NSDate *)date;

/**
 *  datePicker设置最小年份和最大年份
 */
-(void)setupMinYear:(NSInteger)minYear maxYear:(NSInteger)maxYear;
@end
