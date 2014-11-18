//
// HYFacetValue.m
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

@implementation HYFacetValue

- (void)setSelected:(BOOL)selected {
    _selected = selected;

    if (self.query) {
        if (_selected) {
            [self.query.selectedFacetValues addObject:self];
        }
        else {
            [self.query.selectedFacetValues removeObject:self];
        }
    }
}


@end
