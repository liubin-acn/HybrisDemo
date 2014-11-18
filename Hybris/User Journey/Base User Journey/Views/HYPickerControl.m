//
// HYPickerControl.m
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

#import "HYPickerControl.h"


/// Private interface
@interface HYPickerControl ()

@property (nonatomic, strong) NSIntegerBlock completionBlock;
@property (nonatomic, strong) NSArray *items;
@property (nonatomic) NSInteger selectedPickerIndex;
@property (weak, nonatomic) IBOutlet UIView *blockerView;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UIPickerView *picker;

- (IBAction)closePicker:(id)sender;

@end


@implementation HYPickerControl

- (void)awakeFromNib {
    [self.doneButton setTitle:NSLocalizedString(@"Done", @"Title for the done button.")];
    [self.cancelButton setTitle:NSLocalizedString(@"Cancel", @"Title for the cancel button.")];
}


+ (void)showPickerWithValues:(NSArray *)values labels:(NSArray *)labels index:(NSInteger)index completionBlock:(NSIntegerBlock)completionBlock {
    HYPickerControl *pickerControl = [[[NSBundle mainBundle] loadNibNamed:@"HYPickerControl" owner:self options:nil] objectAtIndex:0];
    UIWindow *mainWindow = [[HYAppDelegate sharedDelegate] window];

    pickerControl.blockerView.frame = mainWindow.frame;
    [mainWindow addSubview:pickerControl.blockerView];
    [mainWindow addSubview:pickerControl];

    // Use alternative labels if we have them
    if (labels) {
        pickerControl.items = labels;
    }
    else {
        pickerControl.items = values;
    }
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        pickerControl.picker.backgroundColor = [UIColor whiteColor];
    }
    
    pickerControl.selectedPickerIndex = index;
    pickerControl.completionBlock = completionBlock;
    [pickerControl.picker reloadAllComponents];

    if (index < values.count) {
        [pickerControl.picker selectRow:index inComponent:0 animated:NO];
    }

    [pickerControl setFrame:CGRectMake(0.0f, pickerControl.frame.size.height, pickerControl.frame.size.width, pickerControl.frame.size.height)];

    [UIView animateWithDuration:0.3 animations:^(void) {
            [pickerControl setFrame:mainWindow.frame];
        } completion:^(BOOL finished) { }];
}


- (IBAction)closePicker:(id)sender {
    if (sender == self.doneButton) {
        if (self.completionBlock) {
            self.completionBlock(self.selectedPickerIndex);
        }
    }

    // remove self
    [UIView animateWithDuration:0.3 animations:^(void) {
            [self setFrame:CGRectMake (0.0f, self.frame.size.height, self.frame.size.width, self.frame.size.height)];
        } completion:^(BOOL finished) {
            [self.blockerView removeFromSuperview];
            [self removeFromSuperview];
        }];
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.selectedPickerIndex = row;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSUInteger numRows = [self.items count];

    return numRows;
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}


- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [NSString stringWithFormat:@"%@", [self.items objectAtIndex:row]];
}


+ (NSMutableArray *)arrayFromQuantity:(NSInteger)quantity withZero:(BOOL)includeZero {
    NSMutableArray *strings = [NSMutableArray array];
    NSInteger startingIndex = includeZero ? 0 : 1;

    for (int i = startingIndex; i <= quantity; i++) {
        [strings addObject:[NSString stringWithFormat:@"%i", i]];
    }

    return strings;
}


@end
