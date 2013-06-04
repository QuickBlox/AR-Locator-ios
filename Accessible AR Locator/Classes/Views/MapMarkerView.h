//
//  MapPinView.h
//  Accessible AR Locator
//
//  Created by QuickBlox developers on 3/28/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlaceAnnotation.h"

/** Map Pin View class */
@interface MapMarkerView : MKAnnotationView {
    UIView *container;
}

@property (nonatomic, assign) UILabel *placeTitle;
@property (nonatomic, assign) UILabel *placeAddress;
@property (nonatomic, retain) PlaceAnnotation *annotation;
@property (nonatomic, retain) UIImageView *userNameBG;

@property (assign, nonatomic) id target;
@property SEL action;

- (void)updateAnnotation:(PlaceAnnotation *)_annotation;
- (void)updateCoordinate:(CLLocationCoordinate2D)newCoordinate;

@end
