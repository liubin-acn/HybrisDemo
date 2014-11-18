//
// HYFormViewController.m
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

#import "HYFormViewController.h"
#import "HYFormSwitchCell.h"
#import "HYFormTextEntryCell.h"
#import "HYFormSecureTextEntryCell.h"
#import "HYFormTextSelectionCell.h"

typedef enum {
    NoAutoCorrect = UITextAutocapitalizationTypeNone,
    WordsAutoCorrect = UITextAutocapitalizationTypeWords,
    SentencesAutoCorrect = UITextAutocapitalizationTypeSentences,
} HYFormAutoCorrect;


typedef enum {
    DefaultKeyBoard = UIKeyboardTypeDefault,
    EmailKeyBoard = UIKeyboardTypeEmailAddress,
} HYFormKeyBoardType;


@interface HYFormViewController ()

@property (nonatomic, weak) UITextField *activeField;
@property (nonatomic, strong) NSArray *keyboardType;
@property (nonatomic, strong) NSArray *autoCorrectStatus;
@property (nonatomic, strong) NSArray *autoCapitalizeStatus;
@property (nonatomic, strong) UIToolbar *buttonToolbar;
@property (nonatomic, strong) NSMutableArray* textFieldArray;
@property (nonatomic, strong) UIBarButtonItem *previousButton;
@property (nonatomic, strong) UIBarButtonItem *nextButton;

@end


@implementation HYFormViewController

@synthesize entries = _entries;
@synthesize delegate = _delegate;


- (void)setValid:(BOOL)valid {
    if (_valid != valid) {
        _valid = valid;
        self.navigationItem.rightBarButtonItem.enabled = _valid;
    }
}



#pragma mark - Methods

- (id)initWithPlistNamed:(NSString *)plist {
    self = [super initWithNibName:@"HYFormViewController" bundle:[NSBundle mainBundle]];

    if (self) {
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.entries = [PListSerialisation dataFromBundledPlistNamed:plist];
    }
    
    self.keyboardType =
        [NSArray arrayWithObjects:@"UIKeyboardTypeDefault", @"UIKeyboardTypeASCIICapable", @"UIKeyboardTypeNumbersAndPunctuation", @"UIKeyboardTypeURL",
        @"UIKeyboardTypePhonePad", @"UIKeyboardTypeNumberPad", @"UIKeyboardTypeNamePhonePad", @"UIKeyboardTypeEmailAddress", nil];

    self.autoCapitalizeStatus =
        [NSArray arrayWithObjects:@"UITextAutocapitalizationTypeNone", @"UITextAutocapitalizationTypeWords", @"UITextAutocapitalizationTypeSentences",
        @"UITextAutocapitalizationTypeAllCharacters", nil];

    self.autoCorrectStatus = [NSArray arrayWithObjects:@"UITextAutocorrectionTypeDefault", @"UITextAutocorrectionTypeNo", @"UITextAutocorrectionTypeYes", nil];

    return self;
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Register notification when the keyboard will be show
    [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(keyboardWillShow:)
        name:UIKeyboardWillShowNotification
        object:nil];

    // Register notification when the keyboard will be hide
    [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(keyboardWillHide:)
        name:UIKeyboardWillHideNotification
        object:nil];

    // Add tap recognizer for whole view (for keybaord dismissing)
    UITapGestureRecognizer *tapDetector = [[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(findAndResignFirstResponder)];
    tapDetector.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapDetector];
    self.navigationItem.rightBarButtonItem = UIBarButtonPlain(NSLocalizedString(@"Submit", @"Button title for saving form values"), @selector(submitAction:));
    self.navigationItem.rightBarButtonItem.enabled = self.valid;
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];    
    
    self.tableView.backgroundView.backgroundColor = [UIColor clearColor];
}


- (void)viewWillDisappear:(BOOL)animated {
    // Unregister notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];

    [self.view findAndResignFirstResponder];

    for (UIGestureRecognizer *recognizer in self.view.gestureRecognizers) {
        [self.view removeGestureRecognizer:recognizer];
    }
    
    self.activeField = nil;
    [super viewWillDisappear:animated];
}


- (void)setEntries:(NSMutableArray *)entries {
    _entries = entries;
    
    [self.tableView reloadData];
}


- (void)validateAllFields {
    for (NSInteger i = 0; i < self.entries.count; i++) {
        if (![self fieldIsValidAtIndex:i]) {
            self.valid = NO;
            return;
        }
    }
    self.valid = YES;
}


- (void)showFieldInvalidMessage:(BOOL)shown index:(NSInteger)index {
    if (shown) {
        [[self.entries objectAtIndex:index] setObject:@"yes" forKey:@"showerror"];
    }
    else {
        [[self.entries objectAtIndex:index] setObject:@"no" forKey:@"showerror" ];
    }

    if (index < self.entries.count) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        if ([cell isKindOfClass:[HYFormTextEntryCell class]] || [cell isKindOfClass:[HYFormSecureTextEntryCell class]]) {
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView endUpdates];
        }
    }
    else {
        logDebug(@"Index %i out of bounds for table view", index);
    }
}


- (BOOL)fieldIsValidAtIndex:(NSInteger)index {
    NSString *validation = [[self.entries objectAtIndex:index] objectForKey:@"validation"];
    NSString *type = [[self.entries objectAtIndex:index] objectForKey:@"cellIdentifier"];
    
    // Text
    if ([type isEqualToString:@"HYFormTextEntryCell"] || [type isEqualToString:@"HYFormSecureTextEntryCell"]) {
        if (validation) {
            NSString *value = [[self.entries objectAtIndex:index] objectForKey:@"value"];
            
            if (value && !value.isEmpty) {
                NSError *error;
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:validation
                                                                                       options:NSRegularExpressionCaseInsensitive
                                                                                         error:&error];
                NSUInteger numberOfMatches = [regex numberOfMatchesInString:value
                                                                    options:0
                                                                      range:NSMakeRange(0, [value length])];
                logDebug(@"%@, %i", value, numberOfMatches);
                
                if (numberOfMatches == 0) {
                    return NO;
                }
            }
            else if ([[[self.entries objectAtIndex:index] objectForKey:@"required"] boolValue]) {
                return NO;
            }
        }
    }
    // Choice
    else if ([type isEqualToString:@"HYFormTextSelectionCell"]) {
        if (![[self.entries objectAtIndex:index] objectForKey:@"value"]) {
            return NO;
        }
    }
    return YES;
}


- (void)submitAction:(id)sender {
    [self.view findAndResignFirstResponder];
    NSMutableArray *mutableEntries = [[NSMutableArray alloc] init];

    for (NSDictionary *entry in _entries) {
        if (entry && [entry objectForKey:@"value"]) {
            if ([entry objectForKey:@"value"]) {
                [mutableEntries addObject:[entry objectForKey:@"value"]];
            }
        }
        else {
            [mutableEntries addObject:@""];
        }
    }

    if ([self.delegate respondsToSelector:@selector(submitWithArray:)]) {
        [self.delegate submitWithArray:mutableEntries];
    }
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.entries.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *cellData = [self.entries objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[cellData objectForKey:@"cellIdentifier"]];

    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:[cellData objectForKey:@"cellIdentifier"] owner:self options:nil] objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    UIKeyboardType keyboardType = [self.keyboardType indexOfObject:[cellData objectForKey:@"keyboardType"]];
    UITextAutocorrectionType autoCorrectStatus = [self.autoCorrectStatus indexOfObject:[cellData objectForKey:@"autoCorrectStyle"]];
    UITextAutocapitalizationType autoCapitalizeStatus = [self.autoCapitalizeStatus indexOfObject:[cellData objectForKey:@"autoCapitalizeType"]];

    if ([cell isKindOfClass:[HYFormSwitchCell class]]) {
        [((HYFormSwitchCell *)cell).switchView addTarget:self action:@selector(switchAction:)forControlEvents:UIControlEventValueChanged];
        [((HYFormSwitchCell *)cell).switchView setOn:[[cellData objectForKey:@"value"] boolValue]];
        ((HYFormSwitchCell *)cell).titleLabel.text = [cellData objectForKey:@"title"];
    }

    if ([cell isKindOfClass:[HYFormTextEntryCell class]]) {
        ((HYFormTextEntryCell *)cell).titleLabel.text = [cellData objectForKey:@"title"];
        [((HYFormTextEntryCell *)cell).textField addTarget:self action:@selector(textChangedInTextField:) forControlEvents:UIControlEventEditingChanged];
        ((HYFormTextEntryCell *)cell).textField.placeholder = [cellData objectForKey:@"title"];
        ((HYFormTextEntryCell *)cell).textField.tag = indexPath.row;
        ((HYFormTextEntryCell *)cell).textField.delegate = self;
        ((HYFormTextEntryCell *)cell).textField.text = [cellData objectForKey:@"value"];
        ((HYFormTextEntryCell *)cell).textField.keyboardType = keyboardType;
        ((HYFormTextEntryCell *)cell).textField.autocorrectionType = autoCorrectStatus;
        ((HYFormTextEntryCell *)cell).textField.autocapitalizationType = autoCapitalizeStatus;
        ((HYFormTextEntryCell *)cell).messageField.textColor = UIColor_warningTextColor;
        
        if ([cellData objectForKey:@"error"]) {
            ((HYFormTextEntryCell *)cell).messageField.text = [cellData objectForKey:@"error"];
        }
        
        if ([[[self.entries objectAtIndex:indexPath.row] objectForKey:@"showerror"] isEqualToString:@"yes"]) {
            ((HYFormTextEntryCell *)cell).titleLabel.textColor = UIColor_warningTextColor;
        }
        else {
            ((HYFormTextEntryCell *)cell).titleLabel.textColor = UIColor_textColor;
            ((HYFormTextEntryCell *)cell).messageField.hidden = YES;
        }
    }

    if ([cell isKindOfClass:[HYFormSecureTextEntryCell class]]) {
        ((HYFormTextEntryCell *)cell).titleLabel.text = [cellData objectForKey:@"title"];
        [((HYFormSecureTextEntryCell *)cell).textField addTarget:self action:@selector(textChangedInTextField:) forControlEvents:UIControlEventEditingChanged];
        ((HYFormSecureTextEntryCell *)cell).textField.placeholder = [cellData objectForKey:@"title"];
        ((HYFormSecureTextEntryCell *)cell).textField.tag = indexPath.row;
        ((HYFormSecureTextEntryCell *)cell).textField.delegate = self;
        ((HYFormSecureTextEntryCell *)cell).textField.text = [cellData objectForKey:@"value"];
        ((HYFormSecureTextEntryCell *)cell).textField.keyboardType = keyboardType;
        ((HYFormSecureTextEntryCell *)cell).textField.autocorrectionType = autoCorrectStatus;
        ((HYFormSecureTextEntryCell *)cell).textField.autocapitalizationType = autoCapitalizeStatus;
        ((HYFormSecureTextEntryCell *)cell).messageField.textColor = UIColor_warningTextColor;
        
        if ([cellData objectForKey:@"error"]) {
            ((HYFormSecureTextEntryCell *)cell).messageField.text = [cellData objectForKey:@"error"];
        }
        
        if ([[[self.entries objectAtIndex:indexPath.row] objectForKey:@"showerror"] isEqualToString:@"yes"]) {
            ((HYFormSecureTextEntryCell *)cell).titleLabel.textColor = UIColor_warningTextColor;
        }
        else {
            ((HYFormSecureTextEntryCell *)cell).titleLabel.textColor = UIColor_textColor;
            ((HYFormSecureTextEntryCell *)cell).messageField.hidden = YES;
        }
    }

    if ([cell isKindOfClass:[HYFormTextSelectionCell class]]) {
        if ([cellData objectForKey:@"value"]) {
             ((HYFormTextSelectionCell *)cell).currentSelectionLabel.text = [cellData objectForKey:@"value"];
        }
        else {
            ((HYFormTextSelectionCell *)cell).currentSelectionLabel.text = [cellData objectForKey:@"default"];
            ((HYFormTextSelectionCell *)cell).titleLabel.textColor = [UIColor lightGrayColor];

        }

        ((HYFormTextSelectionCell *)cell).titleLabel.text = [cellData objectForKey:@"title"];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }

    return cell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[tableView cellForRowAtIndexPath:indexPath] isKindOfClass:[HYFormTextSelectionCell class]]) {
        HYPickerViewController *vc = [[HYPickerViewController alloc] initWithNibName:@"HYPickerViewController" bundle:nil];
        vc.values = [[self.entries objectAtIndex:indexPath.row] objectForKey:@"values"];
        vc.delegate = self;
        [self setShowPlainBackButton:YES];
        [self.navigationController pushViewController:vc animated:YES];
    } else if ([[tableView cellForRowAtIndexPath:indexPath] isKindOfClass:[HYFormTextEntryCell class]]) {
        HYFormTextEntryCell *cell = (HYFormTextEntryCell *) [tableView cellForRowAtIndexPath:indexPath];
        [cell.textField becomeFirstResponder];
    } else if ([[tableView cellForRowAtIndexPath:indexPath] isKindOfClass:[HYFormSecureTextEntryCell class]]) {
        HYFormSecureTextEntryCell *cell = (HYFormSecureTextEntryCell *) [tableView cellForRowAtIndexPath:indexPath];
        [cell.textField becomeFirstResponder];
    }
}


- (void)resignKeyboard {
    [self.activeField resignFirstResponder];
}


- (void)checkToolBarButtonStatus {
}


- (void)buttonPressed:(id) sender {
    UITableViewCell *cell = (UITableViewCell *)[[self.activeField superview] superview];
    
    NSIndexPath *idx = [self.tableView indexPathForCell:cell];
    
    NSInteger newNext = [idx indexAtPosition:idx.length -1] +1;
    NSIndexPath *plusPath = [[idx indexPathByRemovingLastIndex] indexPathByAddingIndex:newNext];
    
    NSInteger newPrevious = [idx indexAtPosition:idx.length -1] -1;
    NSIndexPath *previousPath = [[idx indexPathByRemovingLastIndex] indexPathByAddingIndex:newPrevious];
    
    NSIndexPath *selectedIndex;
    UITableViewCell *nextCell;
    if (sender == self.previousButton) {
        nextCell = (UITableViewCell *)[self.tableView cellForRowAtIndexPath:previousPath];
        selectedIndex = previousPath;

    }
    else if (sender == self.nextButton) {
        nextCell = (UITableViewCell *)[self.tableView cellForRowAtIndexPath:plusPath];
        selectedIndex = plusPath;
    }
    
    if ([nextCell isKindOfClass:[HYFormTextEntryCell class]] || [nextCell isKindOfClass:[HYFormSecureTextEntryCell class]]) {
        self.activeField = ((HYFormTextEntryCell *)nextCell).textField;
        [self.activeField becomeFirstResponder];
        [self.tableView scrollToRowAtIndexPath:selectedIndex atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
    else if ([nextCell isKindOfClass:[HYFormTextSelectionCell class]]) {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex.row inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
        HYPickerViewController *vc = [[HYPickerViewController alloc] initWithNibName:@"HYPickerViewController" bundle:nil];
        vc.values = [[self.entries objectAtIndex:selectedIndex.row] objectForKey:@"values"];
        vc.delegate = self;
        [self setShowPlainBackButton:YES];
        [self.activeField resignFirstResponder];
        [self.navigationController pushViewController:vc animated:YES];
    }

}



#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.activeField = textField;
 
    UITableViewCell *cell = (UITableViewCell *)[[textField superview] superview];
    [self.tableView scrollToRowAtIndexPath:[self.tableView indexPathForCell:cell] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    
    if (!self.buttonToolbar) {
        
        self.buttonToolbar = [[UIToolbar alloc] init] ;
        [self.buttonToolbar setBarStyle:UIBarStyleBlackOpaque];
        [self.buttonToolbar sizeToFit];
        self.previousButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Previous", @"Text for previous button above the form keyboard") style:UIBarButtonItemStyleBordered target:self action:@selector(buttonPressed:)];
        self.nextButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Next", @"Text for next button above the form keyboard") style:UIBarButtonItemStyleBordered target:self action:@selector(buttonPressed:)];
        UIBarButtonItem *doneButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(resignKeyboard)];
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

        NSArray *itemsArray = [NSArray arrayWithObjects:self.previousButton, self.nextButton, flexibleSpace, doneButton, nil];
        
        [self.buttonToolbar setItems:itemsArray];
        
    }
    [self.activeField setInputAccessoryView:self.buttonToolbar];
}


- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.text) {
        [[self.entries objectAtIndex:textField.tag] setObject:textField.text forKey:@"value"];
    }

    [textField resignFirstResponder];

    if ([self fieldIsValidAtIndex:textField.tag]) {
        [self showFieldInvalidMessage:NO index:textField.tag];
        [self validateAllFields];
    }
    else {
        [self showFieldInvalidMessage:YES index:textField.tag];
        self.valid = NO;
    }
}


- (void)textChangedInTextField:(UITextField *)textField {
    if (textField.text) {
        [[self.entries objectAtIndex:textField.tag] setObject:textField.text forKey:@"value"];
    }
    
    if ([self fieldIsValidAtIndex:textField.tag]) {
        id object = [[textField superview] superview];
        
        if ([object respondsToSelector:@selector(titleLabel)]) {
            [[object titleLabel] setTextColor:UIColor_textColor];
        }

        [self validateAllFields];
    }
    else {
        id object = [[textField superview] superview];
        
        if ([object respondsToSelector:@selector(titleLabel)]) {
            [[object titleLabel] setTextColor:UIColor_warningTextColor];
        }
        
        self.valid = NO;
    }
}



#pragma mark - UISwitch handling

- (void)switchAction:(UIView *)sender {
    UISwitch *switchView = (UISwitch *)sender;
    UIView *view = sender;
    
    // iOS7: the view hierarchy has changed from iOS6, we loop until we find the UITableViewCell
    while (![view isKindOfClass:[UITableViewCell class]]) {
        view = [view superview];
    }
    
    [[self.entries objectAtIndex:[self.tableView indexPathForCell:(UITableViewCell *)view].row] setObject:[NSNumber numberWithBool:switchView.isOn] forKey:@"value"];
    logDebug(@"Setting -%c- on -%@-", switchView.isOn, [[self.entries objectAtIndex:[self.tableView indexPathForCell:(UITableViewCell *)view].row] objectForKey:@"title"]);
}



#pragma mark - HYPickerViewControllerDelegate

- (void)didSelectValue:(NSString *)value {
    [[self.entries objectAtIndex:[self.tableView indexPathForSelectedRow].row] setObject:value forKey:@"value"];
    logDebug(@"Setting -%@- on -%@-", value, [[self.entries objectAtIndex:[self.tableView indexPathForSelectedRow].row] objectForKey:@"title"]);
    [self.tableView reloadRowsAtIndexPaths:[self.tableView indexPathsForSelectedRows] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.navigationController popViewControllerAnimated:YES];

    if ([self fieldIsValidAtIndex:[self.tableView indexPathForSelectedRow].row]) {
        [self showFieldInvalidMessage:NO index:[self.tableView indexPathForSelectedRow].row];
        [self validateAllFields];
    }
    else {
        [self showFieldInvalidMessage:YES index:[self.tableView indexPathForSelectedRow].row];
        self.valid = NO;
    }

}



#pragma mark - Keyboard

- (void)keyboardWillShow:(NSNotification *)notification {
    CGRect keyboardBounds;

    [[notification.userInfo valueForKey:UIKeyboardFrameBeginUserInfoKey] getValue:&keyboardBounds];

    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];

    [UIView animateWithDuration:0.3f animations:^{
            CGRect frame = self.tableView.frame;

            if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
                frame.size.height -= keyboardBounds.size.height - self.tabBarController.tabBar.frame.size.height;
            }
            else {
                frame.size.height -= keyboardBounds.size.width - self.tabBarController.tabBar.frame.size.height;
            }

            self.tableView.frame = frame;

            // Scroll to make the cell visible
            if (self.activeField) {
                UITableViewCell *cell = (UITableViewCell *)[[self.activeField superview] superview];
                [self.tableView scrollToRowAtIndexPath:[self.tableView indexPathForCell:cell] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
            }
        }];
}


- (void)keyboardWillHide:(NSNotification *)notification {
    CGRect keyboardBounds;

    [[notification.userInfo valueForKey:UIKeyboardFrameBeginUserInfoKey] getValue:&keyboardBounds];

    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];

    [UIView animateWithDuration:0.3f animations:^{
            CGRect frame = self.tableView.frame;

            if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
                frame.size.height += keyboardBounds.size.height - self.tabBarController.tabBar.frame.size.height;
            }
            else {
                frame.size.height += keyboardBounds.size.width - self.tabBarController.tabBar.frame.size.height;
            }

            self.tableView.frame = frame;
        }];
}


@end
