//
//  NSArray+Utilities.m
//  Hybris
//

@implementation NSArray (Utilities)

+ (NSArray *)arrayFromCollection:(id)collection {
    if ([collection isKindOfClass:[NSArray class]]) {
        return (NSArray *)collection;
    }
    else {
        return [[NSArray alloc] initWithObjects:collection, nil];
    }
}


- (BOOL)writeToPlistFile:(NSString *)filename {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:filename];
    BOOL didWriteSuccessfull = [data writeToFile:path atomically:YES];

    return didWriteSuccessfull;
}


+ (NSArray *)readFromPlistFile:(NSString *)filename {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:filename];
    NSData *data = [NSData dataWithContentsOfFile:path];

    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}


@end
