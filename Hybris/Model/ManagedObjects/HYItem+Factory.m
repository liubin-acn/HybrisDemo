//
// HYItem+Factory.m
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

@implementation HYItem (Factory)

+ (void)decorateCell:(UITableViewCell *)cell withObject:(HYObject *)object {
    HYItem *item = (HYItem *)object;

    cell.textLabel.text = (item.name.length) ? item.name : @"Unpopulated";
    //cell.detailTextLabel.text = [NSString stringWithFormat:@"%i", item.children.count];
}


- (NSPredicate *)basePredicate {
    return [NSPredicate predicateWithFormat:@"%@ IN queries", self];
}


+ (HYItem *)objectWithInfo:(NSDictionary *)info {
    HYItem *item = [[HYItem alloc] init];

    [item setValuesForKeysWithDictionary:info];
    item.internalClass = NSStringFromClass([item class]);
    return item;
}


@end
