//
//  ARMarkerView.h
//  Accessible AR Locator
//
//  Created by QuickBlox developers on 3/26/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "PlaceAnnotation.h"

@interface ARMarkerView : UIView {
    
}

@property (nonatomic, assign) UILabel *placeTitle;
@property (nonatomic, assign) UILabel *placeAddress;
@property (nonatomic, retain) PlaceAnnotation *placeAnnotation;
@property (nonatomic, assign) UILabel *distanceLabel;
@property (nonatomic, assign) int distance;

@property (assign, nonatomic) id target;
@property SEL action;

- (id)initWithGeoPoint:(PlaceAnnotation *)_placeAnnotation;
- (CLLocationDistance)updateDistance:(CLLocation *)newOriginLocation;
- (void)updateCoordinate:(CLLocationCoordinate2D)newCoordinate;

@end