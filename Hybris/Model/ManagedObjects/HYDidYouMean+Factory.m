//
// HYDidYouMean+Factory.m
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

@implementation HYDidYouMean (Factory)

+ (HYDidYouMean *)objectWithInfo:(NSDictionary *)info {
    HYDidYouMean *item = [[HYDidYouMean alloc] init];

    [item setValuesForKeysWithDictionary:info];
//    HYQuery *query = [info objectForKey:@"query"];
//    if (query) {
//        item.query = query;
//    }

    item.internalClass = NSStringFromClass([HYDidYouMean class]);
    item.name = [info valueForKey:@"suggestion"];

    return item;
}


+ (void)decorateCell:(UITableViewCell *)cell withObject:(HYObject *)object {
    HYDidYouMean *item = (HYDidYouMean *)object;

    cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Did you mean \"%1$@\"?", @"Did you mean...?"), item.name];

    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"disclosure.png"] highlightedImage:[UIImage imageNamed:@"disclosure-on.png"]];
}


@end
