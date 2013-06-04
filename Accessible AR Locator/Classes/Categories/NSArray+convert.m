//
//  NSArray+convert.m
//  Accessible AR Locator
//
//  Created by QuickBlox developers on 3/22/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "NSArray+convert.h"

@implementation NSArray (convert)

- (NSString *) stringValue{
    NSMutableString *stringPresentation = [[NSMutableString alloc] init];
    for (id item in self) {
        [stringPresentation appendFormat:@"%@", item];
    }
    return [stringPresentation autorelease]; 
}

- (NSString *) stringComaSeparatedValue{
    NSMutableString *stringPresentation = [[NSMutableString alloc] init];
    id lastObject = [self lastObject];
    for (id item in self) {
        if(lastObject == item){
            [stringPresentation appendFormat:@"%@", item];
        }else{
            [stringPresentation appendFormat:@"%@,", item];
        }
    }
    
    return [stringPresentation autorelease]; 
}

@end
