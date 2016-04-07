//
//  DatePickerView.m
//  DLDatePicker
//
//  Created by 东方汇融 on 16/4/7.
//  Copyright © 2016年 cc.umoney. All rights reserved.
//

#import "DatePickerView.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

#define kWeakSelf autoreleasepool {} __weak typeof(self) p_self_weak = self;
#define kStrongSelf autoreleasepool {} __strong typeof(p_self_weak) self = p_self_weak;

static const CGFloat kAnimateDurationOfBackgroundView = 0.25;
static const CGFloat kHeightForPickerView = 216;
static const CGFloat kHeightForToolBarView = 40;
static const void * kPickerViewKey = &kPickerViewKey;

#pragma mark - toolBar class

@interface DLToolBarView : UIView

- (void)confirmButtonActionBlock:(nonnull void(^)(UIButton *btn))block;
- (void)cancelButtonActionBlock:(nonnull void(^)(UIButton *btn))block;

@end

@interface DLToolBarView ()

@property (nonatomic,strong) UIButton *cancelButton;
@property (nonatomic,strong) UIButton *confirmButton;

@property (nonatomic,copy) void(^confirmActionBlock)();
@property (nonatomic,copy) void(^cancelActionBlock)();

@end

@implementation DLToolBarView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:00/255.0f green:192/255.0f blue:233/255.0f alpha:1];

        [self addSubview:self.cancelButton];
        [self addSubview:self.confirmButton];
        
        [self initLayout];
    }
    return self;
}

#pragma mark - public

- (void)confirmButtonActionBlock:(void (^)(UIButton *))block {
    NSAssert(block, @"block can't nil");
    self.confirmActionBlock = [block copy];
}

- (void)cancelButtonActionBlock:(void (^)(UIButton *))block {
    NSAssert(block, @"block can't nil");
    self.cancelActionBlock = [block copy];
}

#pragma mark - private

- (void)initLayout {
    self.cancelButton.frame = CGRectMake(0, 0, 60, CGRectGetHeight(self.frame));
    self.confirmButton.frame = CGRectMake(CGRectGetWidth(self.frame) - 60 , 0, 60, CGRectGetHeight(self.frame));
}

- (__kindof UIButton * _Nonnull)p_initPropertiesForButtonWithTitle:(NSString *)title {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    return button;
}

- (void)p_confirmActon:(UIButton *)sender {
    NSAssert(self.confirmActionBlock, @"block can't nil");
    self.confirmActionBlock(sender);
}

- (void)p_cancelActon:(UIButton *)sender {
    NSAssert(self.cancelActionBlock, @"block can't nil");
    self.cancelActionBlock(sender);
}

#pragma mark - getter

- (UIButton *)cancelButton {
    return _cancelButton?:(_cancelButton = ({
        UIButton *btn = [self p_initPropertiesForButtonWithTitle:@"取消"];
        [btn addTarget:self action:@selector(p_cancelActon:) forControlEvents:UIControlEventTouchUpInside];
        btn;
    }));
}

- (UIButton *)confirmButton {
    return _confirmButton?:(_confirmButton = ({
        UIButton *btn = [self p_initPropertiesForButtonWithTitle:@"确定"];
        [btn addTarget:self action:@selector(p_confirmActon:) forControlEvents:UIControlEventTouchUpInside];
        btn;
    }));
}

@end


@interface DatePickerView()

@property (nonatomic,strong) UIView *backgroundView;

@property (nonatomic,strong) UIDatePicker *datePicker;

@property (nonatomic,strong) DLToolBarView *toolBarView;

@end

@implementation DatePickerView

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [[UIApplication sharedApplication].keyWindow addSubview:self.backgroundView];
        
        [self.backgroundView addSubview:self.datePicker];
        [self.backgroundView addSubview:self.toolBarView];
        
        [self p_initLayout];
        
    }
    return self;
}

#pragma mark - public

- (void)showView {
    CGRect frameForPicker = self.datePicker.frame;
    frameForPicker.origin.y = frameForPicker.origin.y - kHeightForPickerView - kHeightForToolBarView;
    
    __block CGRect frameForToolBar = self.toolBarView.frame;
    frameForToolBar.origin.y = frameForToolBar.origin.y - kHeightForToolBarView - kHeightForPickerView;
    
    [UIView animateWithDuration:kAnimateDurationOfBackgroundView animations:^{
        self.backgroundView.alpha = 1;
        self.datePicker.frame = frameForPicker;
        self.toolBarView.frame = frameForToolBar;
    }];
}

- (void)dismissView {
    CGRect frameForPicker = self.datePicker.frame;
    frameForPicker.origin.y += kHeightForPickerView + kHeightForToolBarView;
    
    CGRect frameForToolBar = self.toolBarView.frame;
    frameForToolBar.origin.y = CGRectGetHeight(self.backgroundView.frame);
    
    [UIView animateWithDuration:kAnimateDurationOfBackgroundView animations:^{
        self.backgroundView.alpha = 0;
        self.datePicker.frame = frameForPicker;
        self.toolBarView.frame = frameForToolBar;
    } completion:^(BOOL finished) {
        [self.backgroundView removeFromSuperview];
        
        // dealloc self
        objc_setAssociatedObject(self, kPickerViewKey, nil, OBJC_ASSOCIATION_ASSIGN);
    }];
}

#pragma mark - private

- (void)p_initLayout {
    self.backgroundView.frame = [UIApplication sharedApplication].keyWindow.frame;
    
    self.datePicker.frame = CGRectMake(0, CGRectGetHeight([UIScreen mainScreen].bounds) + kHeightForToolBarView, CGRectGetWidth(UIScreen.mainScreen.bounds), kHeightForPickerView);
    
    self.toolBarView.frame = CGRectMake(0, CGRectGetHeight([UIScreen mainScreen].bounds), CGRectGetWidth(UIScreen.mainScreen.bounds), kHeightForToolBarView);
}

- (void)pickerConfirmAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(datePickerViewConfirmAction:selectedDate:)]) {
        NSTimeInterval timeZoneOffset=[[NSTimeZone systemTimeZone] secondsFromGMT];
        NSDate * date=[self.datePicker.date dateByAddingTimeInterval:timeZoneOffset];
        [self.delegate datePickerViewConfirmAction:self selectedDate:date];
    }
}

#pragma mark - getter & setter

- (UIView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [UIView new];
        _backgroundView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0];
        _backgroundView.alpha = 0;
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backgroundView addSubview:btn];
        btn.frame = [UIApplication sharedApplication].keyWindow.frame;
        
        // retain self
        objc_setAssociatedObject(self, kPickerViewKey, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        [btn addTarget:self action:@selector(dismissView) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backgroundView;
}

- (UIDatePicker *)datePicker {
    if (_datePicker == nil) {
        
        self.datePicker = [[UIDatePicker alloc] init];
        _datePicker.backgroundColor = [UIColor whiteColor];
        self.datePicker.datePickerMode = UIDatePickerModeDate;
        
        self.datePicker.locale=[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        
        //NSDate *dateMin=[NSDate date];
        //self.datePicker.minimumDate=dateMin;
        //NSDate *dateMax=[NSDate dateWithTimeIntervalSinceNow:30*24*60*60];
        //self.datePicker.maximumDate=dateMax;
        
    }
    return _datePicker;
}

- (DLToolBarView *)toolBarView {
    return _toolBarView?:(_toolBarView = ({
        DLToolBarView *toolBar = [[DLToolBarView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(UIScreen.mainScreen.bounds), kHeightForToolBarView)];
        @kWeakSelf;
        [toolBar confirmButtonActionBlock:^(UIButton *btn) {
            @kStrongSelf;
            [self pickerConfirmAction];
            [self dismissView];
        }];
        [toolBar cancelButtonActionBlock:^(UIButton *btn) {
            @kStrongSelf;
            [self dismissView];
        }];
        toolBar;
    }));
}

@end
