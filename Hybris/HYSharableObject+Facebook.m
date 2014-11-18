//
// HYSharableObject+Facebook.m
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

@implementation HYSharableObject (Facebook)

- (void)facebookPostFromViewController:(UIViewController *)vc {
    NSString *messageBodyText = [NSString stringWithFormat:@"%1$@\n%2$@",
                                 self.price,
                                 self.text];

    if (self.text == nil) {
        self.text = @"";
    }
    if (self.name == nil) {
        self.name = @"";
    }
    if (self.link == nil) {
        self.link = @"";
    }
    
    NSMutableDictionary *postParams = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
        self.link, @"link",
        self.imageLink, @"picture",
        @"ECommerce App for iPhone", @"name",
        self.name, @"caption",
        messageBodyText, @"description",
        nil];

    [FBRequestConnection startWithGraphPath:@"me/feed" parameters:postParams HTTPMethod:@"POST" completionHandler:^(FBRequestConnection *connection,
            id result,
            NSError *error) {
            NSString *alertTitle;
            NSString *alertText;

            if (error) {
                alertTitle = NSLocalizedString (@"Error", @"Error alert box title");
                alertText = [NSString stringWithFormat:
                    NSLocalizedString (@"There was a problem posting to Facebook", @"Facebook error message")];
            }
            else {
                alertTitle = NSLocalizedString (@"Success", @"Success alert box title");
                alertText = [NSString stringWithFormat:
                    NSLocalizedString (@"Posted to Facebook", @"Facebook success message")];
            }

            // Show the result in an alert
            [[[UIAlertView alloc] initWithTitle:alertTitle
                    message:alertText
                    delegate:self
                    cancelButtonTitle:NSLocalizedString (@"OK", @"OK button")
                    otherButtonTitles:nil]
                show];
        }];
}

@end
