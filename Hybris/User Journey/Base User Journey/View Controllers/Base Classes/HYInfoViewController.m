//
// HYInfoViewController.m
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


#import "HYInfoViewController.h"

#define LABEL_INDEX_IN_CONTENT_ROW 0
#define VALIDATION_INDEX_IN_CONTENT_ROW 1
#define INPUT_INDEX_IN_CONTENT_ROW 2
#define VALIDATION_BORDER_WIDTH  1

@interface HYInfoViewController ()

- (UIView *)viewAtIndex:(NSUInteger)scrollIndex withContentIndex:(NSUInteger)contentIndex;
- (UITextField *)inputFieldAtIndex:(NSUInteger)index;
- (UIView *)validationViewAtIndex:(NSUInteger)index;

@end

@implementation HYInfoViewController

@synthesize values = _values;
@synthesize allTypes = _allTypes;
@synthesize allFields = _allFields;
@synthesize scrollView = _scrollView;

- (id)initWithTitle:(NSString *)myTitle fields:(NSArray *)fields values:(NSArray *)values types:(NSArray *)types {
    if ((self = [super init])) {
        self.allFields = fields;
        self.title = myTitle;
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 416)];
        self.values = values;
        self.allTypes = types;
    }

    return self;
}


- (UIView *)inputRowWithTitle:(NSString *)title andContent:(NSString *)content andContentIndex:(NSUInteger)contentIndex atYPosition:(NSUInteger)rowStart {
    // add text field input
    UITextView *entry = [[UITextView alloc] initWithFrame:CGRectMake(10, rowStart, 300, 35)];

    entry.tag = contentIndex;
    entry.font = UIFont_defaultFont;
    entry.text = content;
    [entry.layer setCornerRadius:7];
    entry.editable = false;
    //entry.backgroundColor = UIColor_textColor;
    return entry;
}


- (UIView *)contentRowWithTitle:(NSString *)title content:(NSString *)content index:(NSUInteger)contentIndex yPosition:(NSUInteger)rowStart {
    UIView *formRow = [[UIView alloc] init];

    formRow.backgroundColor = [UIColor clearColor];

    // add text label
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, 5, 300-10, 20)];

    textLabel.text = title;
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.font = UIFont_defaultFont;

    [formRow addSubview:textLabel];

    // add background validation
    UIView *entryGlow =
        [[UIView alloc] initWithFrame:CGRectMake(10 - VALIDATION_BORDER_WIDTH, textLabel.frame.origin.y+textLabel.frame.size.height+5-VALIDATION_BORDER_WIDTH,
            300+
            (2*VALIDATION_BORDER_WIDTH), 35+(2*VALIDATION_BORDER_WIDTH))];
    entryGlow.backgroundColor = [UIColor clearColor];
    [entryGlow.layer setCornerRadius:7];

    [formRow addSubview:entryGlow];

    UIView *entry =
        [self inputRowWithTitle:title andContent:content andContentIndex:contentIndex atYPosition:textLabel.frame.origin.y+textLabel.frame.size.height+5];
    [formRow addSubview:entry];

    if ([entry isKindOfClass:[UITextView class]]) {
        // if uitextview auto resize once added.
        CGRect frame = entry.frame;
        frame.size.height = ((UITextView *)entry).contentSize.height;
        entry.frame = frame;
    }

    // add form row view to scroll view.
    int rowHeight = entry.frame.origin.y+entry.frame.size.height+5;
    formRow.frame = CGRectMake(0, rowStart, 320, rowHeight);

    return formRow;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColor_backgroundColor;

    NSInteger rowStart = 5;

    for (NSInteger i = 0; i < [self.allFields count]; i++) {
        // CREATE FORM ROW
        UIView *contentRow = [self contentRowWithTitle:[self.allFields objectAtIndex:i] content:[self.values objectAtIndex:i] index:i yPosition:rowStart];
        [self.scrollView addSubview:contentRow];
        rowStart += contentRow.frame.size.height;
    }

    // set scroll size.
    self.scrollView.contentSize = CGSizeMake(DEVICE_WIDTH, rowStart);
    [self.view addSubview:self.scrollView];
}


- (UIView *)viewAtIndex:(NSUInteger)scrollIndex withContentIndex:(NSUInteger)contentIndex {
    if ([self.scrollView.subviews count] >= scrollIndex) {
        UIView *contentRow = (UIView *)[self.scrollView.subviews objectAtIndex:scrollIndex];

        if ([contentRow.subviews count] >= contentIndex) {
            return [contentRow.subviews objectAtIndex:contentIndex];
        }
        else {
            return nil;
        }
    }
    else {
        return nil;
    }
}


- (UITextField *)inputFieldAtIndex:(NSUInteger)index {
    return (UITextField *)[self viewAtIndex:index withContentIndex:INPUT_INDEX_IN_CONTENT_ROW];
}


- (UIView *)validationViewAtIndex:(NSUInteger)index {
    return (UIView *)[self viewAtIndex:index withContentIndex:VALIDATION_INDEX_IN_CONTENT_ROW];
}


- (UILabel *)labelViewAtIndex:(NSUInteger)index {
    return (UILabel *)[self viewAtIndex:index withContentIndex:LABEL_INDEX_IN_CONTENT_ROW];
}


@end
