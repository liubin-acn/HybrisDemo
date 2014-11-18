//
// HYSharableObject+Mail.m
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

@implementation HYSharableObject (Mail)

UIViewController *_vc;

- (void)mailFromViewController:(UIViewController *)vc {
    _vc = vc;

    MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
    mailViewController.mailComposeDelegate = self;

    [mailViewController setSubject:self.name];

    NSString *messageBodyText = [NSString stringWithFormat:@"<a href=\"%1$@\">%2$@</a><br/>%3$@<br/>%4$@",
        self.link,
        self.name,
        self.price,
        self.text];

    [mailViewController setMessageBody:messageBodyText isHTML:YES];

    if (mailViewController) {
        [vc presentModalViewController:mailViewController animated:YES];
    }
    else {
        logError(@"Couldn't make mail composer");
    }
}


- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    switch (result) {
        case MFMailComposeResultCancelled: {
//			message.text = @"Result: canceled";
        }
        break;
        case MFMailComposeResultSaved: {
//			message.text = @"Result: saved";
        }
        break;
        case MFMailComposeResultSent: {
//			message.text = @"Result: sent";
        }
        break;
        case MFMailComposeResultFailed: {
//			message.text = @"Result: failed";
        }
        break;
        default: {
//			message.text = @"Result: not sent";
        }
        break;
    }

    [_vc dismissModalViewControllerAnimated:YES];
    _vc = nil;
}


//- (void)launchMailAppOnDevice {
//	NSString *recipients = @"mailto:&subject=";
//	NSString *body = @"&body=";
//
//	NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
//	email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//
//	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
//}

@end
