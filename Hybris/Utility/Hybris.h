//
// Hybris.h
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

#ifndef Hybris_Hybris_h
#define Hybris_Hybris_h

#define PureSingleton(className) \
    + (className *)shared { \
        static className *__main; \
        static dispatch_once_t onceToken; \
        dispatch_once(&onceToken, ^{ __main = [[className alloc] init]; }); \
        return __main; }

#define Singleton(className) \
    static className * __main = nil; \
    +(className *)shared { if (!__main) { __main = [className new]; } return __main; } \
    +(void)clearShared { __main = nil; }

#define UIColorMake(redValue, greenValue, blueValue) \
    [UIColor colorWithRed : redValue/255.0f green : greenValue/255.0f blue : blueValue/255.0f alpha : 1.0]

#define UIColorMakeAlpha(redValue, greenValue, blueValue, alphaValue) \
    [UIColor colorWithRed : redValue/255.0f green : greenValue/255.0f blue : blueValue/255.0f alpha : alphaValue]

#define CGRectAddHeight(_rect, _height) \
    { \
        CGRect t = _rect; \
        t.size.height += _height; \
        _rect = t; \
    }
#define CGRectSetX(_rect, _x) \
    { \
        CGRect t = _rect; \
        t.origin.x = _x; \
        _rect = t; \
    }
#define CGRectSetY(_rect, _y) \
    { \
        CGRect t = _rect; \
        t.origin.y = _y; \
        _rect = t; \
    }
#define CGRectSetWidth(_rect, _width) \
    { \
        CGRect t = _rect; \
        t.size.width = _width; \
        _rect = t; \
    }
#define CGRectSetHeight(_rect, _height) \
    { \
        CGRect t = _rect; \
        t.size.height = _height; \
        _rect = t; \
    }

#define UIBarButtonPlain(TITLE, SELECTOR) \
    [[UIBarButtonItem alloc] initWithTitle:TITLE \
        style:UIBarButtonItemStylePlain target:self action:SELECTOR]

#define UIBarButtonDone(SELECTOR) \
    [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", "Title for the done button.") \
        style:UIBarButtonItemStyleDone target : self action:SELECTOR]

#define UIBarButtonEdit(SELECTOR) \
    [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Edit", "Title for the edit button.") \
        style:UIBarButtonSystemItemEdit target: self action:SELECTOR]

#endif
