//
// HYPickerView.m
// [y] hybris Platform
//
// Copyright (c) 2000-2013 hybris AG
// All rights reserved.
//
// This software is the confidential and proprietary information of hybris
// ("Confidential Information"). You shall not disclose such Confidential
// Information and shall use it only in accordance with the terms of the
// license agreement you entered into with hybris.
//

// Warning: if using, re-enable selectors

#import "HYPickerView.h"

@interface HYPickerView ()
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) UIView *blockerView;
@property (nonatomic, strong) NSMutableArray *components;

@end

@implementation HYPickerView

id _confirmTarget;
HYPickerConfirmBlock confirmBlock;
SEL _confirmAction;

id _changeTarget;
SEL _changeAction;

id _cancelTarget;
SEL _cancelAction;
NSVoidBlock cancelBlock;

@synthesize pickerView = _pickerView;
@synthesize blockerView = _blockerView;
@synthesize components = _components;

+ (HYPickerView *)pickerViewWithComponents:(NSArray *)components withCompletionBlock:(HYPickerConfirmBlock)confirmBlock {
    HYPickerView *picker = [[HYPickerView alloc] init];

    [picker addComponentOptions:components];
    picker.confirmBlock = confirmBlock;
    return picker;
}


- (id)init {
    if (self = [super init]) {
        _components = [[NSMutableArray alloc] init];
        _pickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
        _pickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _pickerView.delegate = self;
        _pickerView.showsSelectionIndicator = true;
        [self setFrame:_pickerView.frame];
        [self addSubview:_pickerView];

        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, _pickerView.frame.size.height, self.frame.size.width, 44)];
        toolbar.barStyle = UIBarStyleBlack;

        UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
            target:self action:@selector(cancelPressed)];

        UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
            target:nil action:nil];

        UIBarButtonItem *confirm = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
            target:self action:@selector(confirmPressed)];

        toolbar.items = [NSArray arrayWithObjects:cancel, spacer, confirm, nil];
        [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height + toolbar.frame.size.height)];
        [self addSubview:toolbar];
    }

    return self;
}


- (void)selectRow:(NSInteger)row animated:(BOOL)animated {
    [_pickerView selectRow:row inComponent:0 animated:animated];
}


- (void)setCancelTarget:(id)target action:(SEL)action {
    _cancelTarget = target;
    _cancelAction = action;
}


- (void)setConfirmTarget:(id)target action:(SEL)action {
    _confirmTarget = target;
    _confirmAction = action;
}


- (void)show:(BOOL)show inView:(UIView *)view animated:(BOOL)animated {
    if ((view != self.superview) && show) {
        _blockerView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        _blockerView.backgroundColor = UIColor_cellBackgroundColor;
        [[[UIApplication sharedApplication] keyWindow] addSubview:_blockerView];

        CGSize pickerSize = [self sizeThatFits:view.bounds.size];
        self.frame = CGRectMake(0, CGRectGetMaxY(view.frame) + 1, pickerSize.width, pickerSize.height);
        [view addSubview:self];
    }

    if (animated) {
        [UIView beginAnimations:@"DatePickerAnimation" context:nil];
        [UIView setAnimationDuration:0.30];
    }

    CGRect frame = self.frame;

    if (show) {
        frame.origin.y = CGRectGetMaxY(view.frame) - frame.size.height;
        _blockerView.hidden = NO;
    }
    else {
        frame.origin.y = CGRectGetMaxY(view.frame) +1;
        _blockerView.hidden = YES;
    }

    self.frame = frame;

    if (animated) {
        [UIView commitAnimations];
    }
}


- (void)confirmPressed {
    if (confirmBlock) {
        confirmBlock(self);
    }
    else {
//        [_confirmTarget performSelector:_confirmAction];
    }

    [self show:FALSE inView:self.superview animated:TRUE];
}


- (void)cancelPressed {
    if (cancelBlock) {
        cancelBlock();
    }
    else if (_confirmTarget && _cancelAction) {
//		[_confirmTarget performSelector:_cancelAction];
    }
    else {
        [self show:FALSE inView:self.superview animated:TRUE];
    }
}


- (void)addComponentOptions:(NSArray *)options {
    [_components addObject:options];
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return _components.count;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    int rows = 0;

    if (component < _components.count) {
        NSArray *options = [_components objectAtIndex:component];
        rows = options.count;
    }

    return rows;
}


- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *option = nil;

    if (component < _components.count) {
        NSArray *options = [_components objectAtIndex:component];

        if (row < options.count) {
            option = [options objectAtIndex:row];
        }
    }

    return option;
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
//	[_changeTarget performSelector:_changeAction];
}


- (void)setChangeValueTarget:(id)target action:(SEL)action {
    _changeAction = action;
    _changeTarget = target;
}


@end
