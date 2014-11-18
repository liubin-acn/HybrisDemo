//
// HYProduct+Factory.m
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

#import "HYProduct+Factory.h"
#import "HYProductCell.h"
#import "Review.h"

@implementation HYProduct (Factory)

- (void)addDetailsFromProduct:(HYProduct *)otherProduct {
    self.potentialPromotions = otherProduct.potentialPromotions;
    // TODO top up with additional data
}


+ (NSString *)mapStockCode:(NSString *)code {
    if ([code isEqualToString:@"inStock"]) {
        return NSLocalizedString(@"In Stock", @"In Stock");
    }
    else if ([code isEqualToString:@"lowStock"]) {
        return NSLocalizedString(@"Low Stock", @"Low Stock");
    }
    else if ([code isEqualToString:@"outOfStock"]) {
        return NSLocalizedString(@"Out Of Stock", @"Out Of Stock");
    }
    else {
        return [NSString stringWithFormat:@"Unknown: %@", code];
    }
}


+ (void)decorateCell:(UITableViewCell *)cell withObject:(HYObject *)object {
    HYProduct *product = (HYProduct *)object;
    HYProductCell *productCell = (HYProductCell *)cell;

    [productCell.imageView setImageWithURL:[NSURL URLWithString:product.thumbnail] placeholderImage:[UIImage imageNamed:HYProductCellPlaceholderImage]];
    productCell.nameLabel.text = product.name;
    productCell.brandLabel.text = product.manufacturer;
    productCell.descriptionLabel.text = product.summary;
    productCell.priceLabel.text = product.displayPrice;
    productCell.stockLevelLabel.text = [HYProduct mapStockCode:product.stockLevelStatus];

    productCell.brandLabel.highlightedTextColor = productCell.brandLabel.textColor;
    productCell.nameLabel.highlightedTextColor = productCell.nameLabel.textColor;
    
    // N.B. product.stockLevel cannot be used here - it's not set!
    
    NSLog(@"product code -------> %@", product.productCode);
}


+ (HYProduct *)objectWithInfo:(NSDictionary *)info {
    NSDictionary *productInfo = [info objectForKey:@"product"];

    if (productInfo == nil) {
        return nil;
    }

    HYProduct *product = [[HYProduct alloc] init];

    //Sets all keys that match properties
    @try {
        [product setValuesForKeysWithDictionary:productInfo];
    }@catch (NSException *exception) {
        logDebug(@"%@", exception);
    }

    product.productCode = [productInfo objectForKey:@"code"];
    product.creationTime = [NSDate date];
    product.internalClass = NSStringFromClass([product class]);
    product.productDescription = [productInfo objectForKey:@"description"];
    product.manufacturer = [productInfo objectForKey:@"manufacturer"];

    // If a product is found by code, it will not have a query
    if ([info objectForKey:@"query"]) {
        product.query = [info objectForKey:@"query"];
    }

    @synchronized(product.query) {
        // Add additional properties that require more depth
        NSArray *imagesData = [productInfo objectForKey:@"images"];

        // Initialise arrays if not already
        if (!product.primaryImageURLs) {
            product.primaryImageURLs = [[NSMutableDictionary alloc] init];
        }

        if (!product.galleryImageURLs) {
            product.galleryImageURLs = [[NSMutableArray alloc] init];
        }

        // Add the images
        if (imagesData) {
            NSMutableDictionary *primaryImages = [NSMutableDictionary dictionary];
            NSMutableArray *galleryImages = [NSMutableArray array];

            for (NSDictionary *imageData in imagesData) {
                if ([[imageData objectForKey:@"format"] isEqualToString:@"thumbnail"] && [[imageData objectForKey:@"imageType"] isEqualToString:@"PRIMARY"]) {
                    product.thumbnail =
                        [NSString stringWithFormat:@"%@%@", [[NSUserDefaults standardUserDefaults] stringForKey:@"web_services_base_url_preference"],
                        [imageData objectForKey:@"url"]];
                }

                if ([[imageData objectForKey:@"imageType"] isEqualToString:@"PRIMARY"]) {
                    [primaryImages setObject:[NSString stringWithFormat:@"%@%@",
                            [[NSUserDefaults standardUserDefaults] stringForKey:@"web_services_base_url_preference"], [imageData objectForKey:@"url"]]
                        forKey:[imageData objectForKey:@"format"]];
                }

                if ([[imageData objectForKey:@"imageType"] isEqualToString:@"GALLERY"]) {
                    NSInteger index = [[imageData objectForKey:@"galleryIndex"] integerValue];

                    if (index >= galleryImages.count) {
                        NSMutableDictionary *galleryImage = [NSMutableDictionary dictionary];
                        [galleryImages insertObject:galleryImage atIndex:index];
                    }

                    [[galleryImages objectAtIndex:index] setObject:[NSString stringWithFormat:@"%@%@",
                            [[NSUserDefaults standardUserDefaults] stringForKey:@"web_services_base_url_preference"], [imageData objectForKey:@"url"]]
                        forKey:[imageData objectForKey:@"format"]];
                }
            }

            product.primaryImageURLs = [NSMutableDictionary dictionaryWithDictionary:primaryImages];
            product.galleryImageURLs = [NSMutableArray arrayWithArray:galleryImages];
        }

        NSDictionary *priceData = [productInfo objectForKey:@"price"];

        if (priceData) {
            product.price = [priceData objectForKey:@"value"];
            product.displayPrice = [priceData objectForKey:@"formattedValue"];
            product.currency = [priceData objectForKey:@"currencyIso"];
            product.priceType = [priceData objectForKey:@"priceType"];
        }

        // Stock
        NSDictionary *stockData = [productInfo objectForKey:@"stock"];

        if (stockData) {
            product.stockLevelStatus = [[stockData objectForKey:@"stockLevelStatus"] objectForKey:@"code"];
            product.stockLevel = [stockData objectForKey:@"stockLevel"];
            
            // Some products have no concept of stock level
            if (product.stockLevel == nil) {
                product.stockLevel = [NSNumber numberWithInt:1];
            }
        }

        // Make a Review for each value
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'hh:mm:ss-hh:mm"];
        NSMutableArray *reviews = [NSMutableArray array];

        for (NSDictionary *reviewDictionary in[productInfo valueForKey : @"reviews"]) {
            Review *review = [[Review alloc] init];
            review.principalName = [[reviewDictionary objectForKey:@"principal"] objectForKey:@"name"];
            review.principalUID = [[reviewDictionary objectForKey:@"principal"] objectForKey:@"uid"];
            review.product = product;
            @try {
                [review setValuesForKeysWithDictionary:reviewDictionary];
            }@catch (NSException *exception) {
                logDebug(@"%@", exception);
            }
            review.date = [NSDate dateFromISO8601String:[reviewDictionary objectForKey:@"date"]];
            [reviews addObject:review];
        }

        product.reviews = reviews;

        // Promotions, an array of dictionaries
        product.potentialPromotions = [productInfo objectForKey:@"potentialPromotions"];

        // Classifications, an array of dictionaries
        product.classifications = [productInfo objectForKey:@"classifications"];

        // Variants
        // Check whether the catalog has variant properties
        NSArray *baseOptionArray = [productInfo objectForKey:@"baseOptions"];
        NSArray *variantOptionsArray = [productInfo objectForKey:@"variantOptions"];

        // Create a dictionary of variants, e.g. style = {variantInstances... }
        NSMutableDictionary *variantDictionary = [NSMutableDictionary dictionary];
        
        product.purchasable = YES;

        // Check whether it's an intermediary product or not
        if ([variantOptionsArray count]) {
            for (NSDictionary *dict in variantOptionsArray) {
                if ([dict objectForKey:@"variantOptionQualifiers"]) {
                    NSMutableDictionary *variantInfo = [[dict objectForKey:@"variantOptionQualifiers"] objectAtIndex:0];
                    NSString *currentVariant = [variantInfo objectForKey:@"name"];

                    // Find or create an array for this variant category
                    NSMutableArray *variantArray;
                    NSMutableDictionary *variantInstance = [NSMutableDictionary dictionary];

                    if ([[variantDictionary allKeys] containsObject:currentVariant]) {
                        variantArray = [variantDictionary objectForKey:currentVariant];
                    }
                    else {
                        variantArray = [NSMutableArray array];
                        [variantDictionary setObject:variantArray forKey:currentVariant];
                    }
                    
                    [variantInstance setObject:[dict objectForKey:@"code"] forKey:@"code"];
                    [variantInstance setObject:[[[dict objectForKey:@"variantOptionQualifiers"] objectAtIndex:0] objectForKey:@"value"] forKey:@"value"];
                    
                    // Some products have no concept of stock level
                    if ([[dict objectForKey:@"stock"] objectForKey:@"stockLevel"] == nil) {
                        [variantInstance setObject:[NSNumber numberWithInt:1] forKey:@"stockLevel"];
                    } else {
                        [variantInstance setObject:[[dict objectForKey:@"stock"] objectForKey:@"stockLevel"] forKey:@"stockLevel"];
                    }

                    [variantArray addObject:variantInstance];
                    
                    /// purchasable?
                    product.purchasable = NO;
                    product.variantInfo = variantDictionary;
                }
            }
        }
        
        if ([baseOptionArray count]) {
            if ([[[productInfo objectForKey:@"baseOptions"] objectAtIndex:0] objectForKey:@"options"]) {
                NSArray *variants = [productInfo valueForKeyPath:@"baseOptions.options"];
                NSArray *selectedVariants = [productInfo valueForKeyPath:@"baseOptions.selected"];

                // Create a dictionary of variant data for the currently selected product
                NSMutableDictionary *selectedVariantDictionary = [NSMutableDictionary dictionary];

                // Create Variant data for selected product
                for (NSDictionary *entry in selectedVariants) {
                    if ([entry objectForKey:@"url"]) {
                        NSMutableDictionary *variantInfo = [[entry objectForKey:@"variantOptionQualifiers"] objectAtIndex:0];
                        NSString *variantInstance = [variantInfo objectForKey:@"value"];
                        NSString *variantClass = [variantInfo objectForKey:@"name"];

                        [selectedVariantDictionary setObject:variantInstance forKey:variantClass];
                    }
                }

                product.selectedVariantInfo = selectedVariantDictionary;

                for (NSArray *variant in variants) {
                    for (NSDictionary *entry in variant) {
                        if ([entry objectForKey:@"variantOptionQualifiers"]) {
                            NSMutableDictionary *variantInfo = [[entry objectForKey:@"variantOptionQualifiers"] objectAtIndex:0];
                            NSString *currentVariant = [variantInfo objectForKey:@"name"];
                            
                            // Find or create an array for this variant category
                            NSMutableArray *variantArray;

                            if ([[variantDictionary allKeys] containsObject:currentVariant]) {
                                variantArray = [variantDictionary objectForKey:currentVariant];
                            }
                            else {
                                variantArray = [NSMutableArray array];
                                [variantDictionary setObject:variantArray forKey:currentVariant];
                            }

                            // Make a new dictionary of values for this variant instance, add to the array associated with the variant category name
                            NSMutableDictionary *variantInstance = [NSMutableDictionary dictionary];

                            // Set the variant dictionary for the product
                            [variantInstance setObject:[[entry objectForKey:@"priceData"] objectForKey:@"formattedValue"] forKey:@"formattedValue"];                            
                            [variantInstance setObject:[entry objectForKey:@"code"] forKey:@"code"];
                            [variantInstance setObject:[variantInfo objectForKey:@"value"] forKey:@"value"];
                            
                            // Some products have no concept of stock level
                            if ([[entry objectForKey:@"stock"] objectForKey:@"stockLevel"] == nil) {
                                [variantInstance setObject:[NSNumber numberWithInt:1] forKey:@"stockLevel"];
                            } else {
                                [variantInstance setObject:[[entry objectForKey:@"stock"] objectForKey:@"stockLevel"] forKey:@"stockLevel"];
                            }

                            if ([variantInstance objectForKey:@"image"]) {
                                [variantInstance setObject:[[variantInfo objectForKey:@"image"] objectForKey:@"url"] forKey:@"imageUrl"];
                            }

                            [variantArray addObject:variantInstance];

                            product.variantInfo = variantDictionary;
                        }
                    }
                }
            }
        }

        product.lastPopulated = [NSDate date];
    }
    
    return product;
}


- (NSPredicate *)basePredicate {
    return nil;
}


+ (void)decoratePromotionsView:(TTTAttributedLabel *)view forPromotionArray:(NSArray *)array {
    if (array && ((NSArray *)array).count) {
        NSDictionary *promotion = [array objectAtIndex:0];

        view.text = [promotion objectForKey:@"description"];


        /*
         *  firedMessages trumps description
         */
        if ([promotion objectForKey:@"firedMessages"] && ((NSDictionary *)[promotion objectForKey:@"firedMessages"]).count) {
            // Convert line breaks
            NSMutableString *mutableDescription = [NSMutableString stringWithString:[[promotion objectForKey:@"firedMessages"] objectAtIndex:0]];
            [mutableDescription replaceOccurrencesOfString:@"<br>" withString:@"\n" options:NSLiteralSearch range:NSMakeRange(0, [mutableDescription length])];

            view.text = [NSString stringWithString:mutableDescription];
        }


        /*
         *  couldFireMessage trumps firedMessage
         *
         *  Builds links in the form appName://product/123456
         *  with the title as the product name
         */

        if ([promotion objectForKey:@"couldFireMessages"] && ((NSDictionary *)[promotion objectForKey:@"couldFireMessages"]).count) {
            view.text = [[promotion objectForKey:@"couldFireMessages"] objectAtIndex:0];

            NSMutableString *mutableDescription = [NSMutableString stringWithString:[[promotion objectForKey:@"couldFireMessages"] objectAtIndex:0]];

            // Convert line breaks
            [mutableDescription replaceOccurrencesOfString:@"<br>" withString:@"\n" options:NSLiteralSearch range:NSMakeRange(0, [mutableDescription length])];

            NSScanner *scanner;

            // Find the links
            NSMutableArray *links = [NSMutableArray array];
            scanner = [NSScanner scannerWithString:mutableDescription];

            while ([scanner isAtEnd] == NO) {
                [scanner scanUpToString:@"<a href=" intoString:NULL];
                NSString *text = nil;
                [scanner scanUpToString:@"</a>" intoString:&text];

                if (text) {
                    text = [NSString stringWithFormat:@"%@</a>", text];
                    [links addObject:[text copy]];
                }
            }

            // The App name, used for the custom URLs
            NSString *appName = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"] lowercaseString];

            // Find the product names
            NSMutableArray *productNames = [NSMutableArray array];
            scanner = [NSScanner scannerWithString:mutableDescription];

            while ([scanner isAtEnd] == NO) {
                [scanner scanUpToString:@"<b>" intoString:NULL];
                NSString *text = nil;
                [scanner scanUpToString:@"</b>" intoString:&text];

                if (text) {
                    NSMutableString *mutableText = [NSMutableString stringWithString:text];
                    [mutableText replaceOccurrencesOfString:@"<b>" withString:@""
                        options:NSLiteralSearch
                        range:NSMakeRange(0, [text length])];
                    [productNames addObject:[mutableText copy]];
                }
            }

            // Find the product codes
            int i = 0;
            NSMutableArray *productCodes = [NSMutableArray array];

            for (NSString *link in links) {
                NSRegularExpression *regexCode = [NSRegularExpression regularExpressionWithPattern:@"[0-9]{6,7}" options:0 error:NULL];
                NSTextCheckingResult *matchCode = [regexCode firstMatchInString:link options:0 range:NSMakeRange(0, [link length])];
                NSString *code = [[link substringWithRange:[matchCode rangeAtIndex:0]] stringByTrimmingWhitespace];
                [productCodes addObject:code];
                [mutableDescription replaceOccurrencesOfString:link withString:[productNames objectAtIndex:i]
                    options:NSLiteralSearch
                    range:NSMakeRange(0, [mutableDescription length])];
                i++;
            }

            // Set the updated description
            view.text = mutableDescription;
            [view sizeToFit];

            // Add the links
            for (int i = 0; i < productCodes.count; i++) {
                NSRange range = [view.text rangeOfString:[productNames objectAtIndex:i]];
                [view addLinkToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@://product/%@", appName,
                            [productCodes objectAtIndex:i]]] withRange:range];
            }
        }

    }
}


@end
