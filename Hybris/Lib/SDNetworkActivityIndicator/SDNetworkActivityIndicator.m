/*
 * This file is part of the SDNetworkActivityIndicator package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

static SDNetworkActivityIndicator *instance;

@implementation SDNetworkActivityIndicator

+ (id)sharedActivityIndicator
{
    if (instance == nil)
    {
        instance = [[SDNetworkActivityIndicator alloc] init];
    }

    return instance;
}

- (id)init
{
    if ((self = [super init]))
    {
        counter = 0;
    }

    return self;
}

- (void)startActivity
{
    @synchronized(self)
    {
        if (counter == 0)
        {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        }
        counter++;
    }
}

- (void)stopActivity
{
    @synchronized(self)
    {
        if (counter > 0 && --counter == 0)
        {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }
    }
}

- (void)stopAllActivity
{
    @synchronized(self)
    {
        counter = 0;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
}

@end
