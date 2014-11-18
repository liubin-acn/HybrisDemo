//
// HYCategory+Factory.m
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

@implementation HYCategory (Factory)

//#pragma mark - Helpers
//- (NSSet *)childCategories {
//    return [self.children objectsPassingTest:^(id obj, BOOL *stop) {
//            return [obj isKindOfClass:[HYCategory class]];
//        }];
//}
//- (NSSet *)products {
//    return [self.children objectsPassingTest:^(id obj, BOOL *stop) {
//            return [obj isKindOfClass:[HYProduct class]];
//        }];
//}
- (NSPredicate *)basePredicate {
    return [NSPredicate predicateWithFormat:@"ANY parents = %@", self];
}


#pragma mark - Tablecell
+ (void)decorateCell:(UITableViewCell *)cell withObject:(HYObject *)object {
    HYCategory *category = (HYCategory *)object;

    cell.textLabel.text = (category.name.length) ? category.name : @"Unpopulated";
    cell.textLabel.font = UIFont_defaultFont;
}


+ (HYCategory *)objectWithInfo:(NSDictionary *)categoryInfo {
    HYCategory *category = [[HYCategory alloc] init];

    [category setValuesForKeysWithDictionary:categoryInfo];

    category.creationTime = [NSDate date];
    category.internalClass = NSStringFromClass([category class]);

    HYQuery *query = [categoryInfo objectForKey:@"query"];

    if (query) {
        category.query = query;
    }

    category.lastPopulated = [NSDate date];

    return category;
}


@end
