//
//  ViewController.m
//  DLDatePicker
//
//  Created by 东方汇融 on 16/4/7.
//  Copyright © 2016年 cc.umoney. All rights reserved.
//

#import "ViewController.h"
#import "DatePickerView.h"

@interface ViewController ()<UITextFieldDelegate,DatePickerViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *text_date;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _text_date.delegate = self;
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    //如果当前要显示的键盘，那么把UIDatePicker（如果在视图中）隐藏
    [_text_date resignFirstResponder];
    DatePickerView *picker = [DatePickerView new];
    picker.delegate = self;
    [picker showView];
    
    return NO;
}

-(void)datePickerViewConfirmAction:(DatePickerView *)pickerView selectedDate:(NSDate *)pickerDate{
    NSString *str_date = [NSString stringWithFormat:@"%@",pickerDate];
    str_date = [str_date substringToIndex:10];
    _text_date.text = str_date;
}



@end
