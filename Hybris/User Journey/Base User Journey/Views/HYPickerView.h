//
// HYPickerView.h
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

@class HYPickerView;

typedef void (^HYPickerConfirmBlock)(HYPickerView *picker);

@interface HYPickerView:UIView<UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, copy)  NSVoidBlock cancelBlock;
@property (nonatomic, copy)  HYPickerConfirmBlock confirmBlock;
@property (nonatomic, readonly) UIPickerView *picker;

+ (HYPickerView *)pickerViewWithComponents:(NSArray *)components withCompletionBlock:(HYPickerConfirmBlock)confirmBlock;

- (void)setChangeValueTarget:(id) target action:(SEL)action;
- (void)setConfirmTarget:(id) target action:(SEL)action;
- (void)setCancelTarget:(id) target action:(SEL)action;
- (void)show:(BOOL) show inView:(UIView *)view animated:(BOOL)animated;
- (void)addComponentOptions:(NSArray *)options;
- (void)selectRow:(NSInteger) row animated:(BOOL)animated;

@end
