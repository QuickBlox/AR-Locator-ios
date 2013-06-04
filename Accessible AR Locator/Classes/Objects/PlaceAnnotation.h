//
//  PlaceAnnotation.h
//  Accessible AR Locator
//
//  Created by QuickBlox developers on 3/28/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>

/** Map Annotation class */
@interface PlaceAnnotation : NSObject <MKAnnotation, NSCoding, NSCopying> {
    
    NSString *placeTitle;
    NSString *placeAddress;
    CLLocationCoordinate2D coordinate;
    NSDate *createdAt;
    
    NSUInteger geoDataID;
    NSUInteger qbPlaceID;
    
    NSInteger distance;
    
}

@property (nonatomic, retain) NSString *placeTitle;
@property (nonatomic, retain) NSString *placeAddress;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSDate *createdAt;

@property (nonatomic, assign) NSUInteger geoDataID;
@property (nonatomic, assign) NSUInteger qbPlaceID;

@property (nonatomic, assign) NSInteger distance;

@end
