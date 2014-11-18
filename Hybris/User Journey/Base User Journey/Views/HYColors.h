//
// HYColors.h
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

#ifndef Hybris_HYColors_h
#define Hybris_HYColors_h


/**
 *  Define colors and fonts here for simple overriding.
 *  More complex customisation should be done in the setup methods
 *  of the corresponding view or view controller.
 */

/// Colors

// App tint color
#undef UIColor_appTint
#define UIColor_appTint                   UIColorMake(251, 225, 1)


// Main text color
#undef UIColor_textColor
#define UIColor_textColor                       UIColorMake(78, 78, 78)

// Light text color
#undef UIColor_lightTextColor
#define UIColor_lightTextColor                       UIColorMake(173, 173, 173)

// Inverse text color
#undef UIColor_inverseTextColor
#define UIColor_inverseTextColor                UIColorMake(255, 255, 255)

// Button text color
#undef UIColor_buttonTextColor
#define UIColor_buttonTextColor                UIColorMake(0, 0, 0)


// Backgrounds
#undef UIColor_backgroundColor
#define UIColor_backgroundColor                UIColorMake(255, 255, 255)

// Table backgrounds
#undef UIColor_tableBackgroundColor
#define UIColor_tableBackgroundColor                UIColorMake(244, 244, 244)

// Cell backgrounds
#undef UIColor_cellBackgroundColor
#define UIColor_cellBackgroundColor            UIColorMake(244, 244, 244)

// Image cell shadow lines
#undef UIColor_dividerLightColor
#define UIColor_dividerLightColor              UIColorMake(233, 234, 235)

#undef UIColor_dividerDarkColor
#define UIColor_dividerDarkColor              UIColorMake(211, 214, 216)

// Dividers, borders, etc
#undef UIColor_dividerBorderColor
#define UIColor_dividerBorderColor              UIColorMake(196, 196, 196)

// Disabled text
#undef UIColor_disabledColor
#define UIColor_disabledColor                   UIColorMake(128, 128, 128)

// Distance text
#undef UIColor_distanceColor
#define UIColor_distanceColor                   UIColorMake(0, 111, 197)

// Warning color (for out of stock, wrong data, etc)
#undef UIColor_warningTextColor
#define UIColor_warningTextColor             UIColorMake(230, 0, 0)

// Branded color text
#undef UIColor_brandTextColor
#define UIColor_brandTextColor                UIColorMake(9, 88, 184)

// Price color text
#undef UIColor_priceTextColor
#define UIColor_priceTextColor                UIColorMake(9, 88, 184)

// Main brand color
#undef UIColor_standardTint
#define UIColor_standardTint                    UIColorMake(35, 53, 72)

// Tab unselected color
#undef UIColor_tabTint
#define UIColor_tabTint                    UIColorMake(124, 136, 147)

#undef UIColor_lightBlueTextTint
#define UIColor_lightBlueTextTint                    UIColorMake(18, 84, 181)

// Brand highlight color
#undef UIColor_highlightTint
#define UIColor_highlightTint                   UIColorMake(255, 201, 73)

// Progress bar
#undef UIColor_progressTintColor
#define UIColor_progressTintColor               UIColorMake(8, 90, 189)

// Progress bar track
#undef UIColor_trackTintColor
#define UIColor_trackTintColor                  UIColorMakeAlpha(255, 255, 255, 0.0)


/// Fonts

#undef UIFont_defaultFont
#define UIFont_defaultFont                      [UIFont fontWithName : @ "HelveticaNeue" size : 13.0f]

#undef UIFont_defaultBoldFont
#define UIFont_defaultBoldFont                      [UIFont fontWithName : @ "HelveticaNeue-Bold" size : 13.0f]

#undef UIFont_buttonFont
#define UIFont_buttonFont                      [UIFont fontWithName : @ "HelveticaNeue-Bold" size : 18.0f]

#undef UIFont_bodyFont
#define UIFont_bodyFont                         [UIFont fontWithName : @ "HelveticaNeue-Medium" size : 13.0f]

#undef UIFont_priceFont
#define UIFont_priceFont                         [UIFont fontWithName : @ "HelveticaNeue-Medium" size : 15.0f]

#undef UIFont_priceLargeFont
#define UIFont_priceLargeFont                         [UIFont fontWithName : @ "HelveticaNeue-Bold" size : 20.0f]

#undef UIFont_headerFooterFont
#define UIFont_headerFooterFont                  [UIFont fontWithName : @ "HelveticaNeue" size : 14.0f]

#undef UIFont_titleFont
#define UIFont_titleFont                        [UIFont fontWithName : @ "HelveticaNeue-Bold" size : 15.0f]

#undef UIFont_promotionFont
#define UIFont_promotionFont                        [UIFont fontWithName : @ "HelveticaNeue-Bold" size : 15.0f]

#undef UIFont_informationLabelFont
#define UIFont_informationLabelFont                        [UIFont fontWithName : @ "HelveticaNeue" size : 15.0f]

#undef UIFont_detailFont
#define UIFont_detailFont                        [UIFont fontWithName : @ "HelveticaNeue" size : 12.0f]

#undef UIFont_detailBoldFont
#define UIFont_detailBoldFont                        [UIFont fontWithName : @ "HelveticaNeue-Bold" size : 12.0f]


#undef UIFont_detailMediumFont
#define UIFont_detailMediumFont                        [UIFont fontWithName : @ "HelveticaNeue-Medium" size : 12.0f]

//
//#undef UIFont_defaultBoldFont
//#define UIFont_defaultBoldFont                  [UIFont fontWithName : @ "HelveticaNeue-Bold" size : 15.0f]
//
//#undef UIFont_bodyBoldFont
//#define UIFont_bodyBoldFont                      [UIFont fontWithName : @ "HelveticaNeue-Bold" size : 13.0f]
//
#undef UIFont_smallFont
#define UIFont_smallFont                        [UIFont fontWithName : @ "HelveticaNeue-Medium" size : 10.0f]

#undef UIFont_smallBoldFont
#define UIFont_smallBoldFont                        [UIFont fontWithName : @ "HelveticaNeue-Bold" size : 10.0f]

//#undef UIFont_extraSmallFont
//#define UIFont_extraSmallFont                        [UIFont fontWithName : @ "HelveticaNeue" size : 10.0f]
//
//#undef UIFont_extraSmallBoldFont
//#define UIFont_extraSmallBoldFont                        [UIFont fontWithName : @ "HelveticaNeue-Bold" size : 10.0f]
//
//#undef UIFont_smallBoldFont
//#define UIFont_smallBoldFont                    [UIFont fontWithName : @ "Helvetica Neue-Bold" size : 12.0f]

#undef UIFont_linkFont
#define UIFont_linkFont                         [UIFont fontWithName : @ "Helvetica Neue-Bold" size : 15.0f]

#undef UIFont_smallLinkFont
#define UIFont_smallLinkFont                         [UIFont fontWithName : @ "Helvetica Neue" size : 10.0f]

#undef UIFont_navigationBarFont
#define UIFont_navigationBarFont                [UIFont fontWithName : @ "HelveticaNeue-Bold" size : 15.0f];

#undef UIFont_variantFont
#define UIFont_variantFont                        [UIFont fontWithName : @ "HelveticaNeue-Bold" size : 17.0f]

#undef UIFont_orderStatusFont
#define UIFont_orderStatusFont                        [UIFont fontWithName : @ "HelveticaNeue-Bold" size : 17.0f]

#endif
