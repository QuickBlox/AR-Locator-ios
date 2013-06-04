//
//  ARGeoCoordinate.h
//  Accessible AR Locator
//
//  Created by QuickBlox developers on 3/26/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "ARCoordinate.h"

@interface ARGeoCoordinate : ARCoordinate {
	CLLocation *geoLocation;
}
@property (nonatomic, retain) CLLocation *geoLocation;

+ (ARGeoCoordinate *)coordinateWithLocation:(CLLocation *)location locationTitle:(NSString*) titleOfLocation;
+ (ARGeoCoordinate *)coordinateWithLocation:(CLLocation *)location fromOrigin:(CLLocation *)origin;

- (void)calibrateUsingOrigin:(CLLocation *)origin;

@end
