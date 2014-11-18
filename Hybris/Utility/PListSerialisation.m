@interface PListSerialisation ()

+ (id)propertyListWithData:(NSData *)plistXML;

@end


@implementation PListSerialisation

+ (id)dataFromBundledPlistNamed:(NSString *)filename {
    NSString *path = [[NSBundle mainBundle] pathForResource:filename ofType:@"plist"];
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:path];

    return [PListSerialisation propertyListWithData:plistXML];
}


+ (id)dataFromPlistAtPath:(NSURL *)filePath {
    NSData *plistXML = [NSData dataWithContentsOfURL:filePath];
    
    return [PListSerialisation propertyListWithData:plistXML];
}


+ (id)propertyListFromString:(NSString *)response {
    NSData *plistXML = [response dataUsingEncoding:NSUTF8StringEncoding];
    
    return [PListSerialisation propertyListWithData:plistXML];
}



#pragma mark - private methods

+ (id)propertyListWithData:(NSData *)plistXML {    
    NSError *error = nil;
    NSPropertyListFormat format;
    
    id dictionary = [NSPropertyListSerialization
                     propertyListWithData:plistXML
                     options:NSPropertyListMutableContainersAndLeaves
                     format:&format
                     error:&error];
    
    if (!dictionary) {
        NSLog(@"Error reading plist: %@, format: %d", error, format);
    }
    
    return dictionary;
}

@end
