//
//  MapViewController.h
//  Accessible AR Locator
//
//  Created by QuickBlox developers on 3/27/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapMarkerView.h"

@interface MapViewController : UIViewController <MKMapViewDelegate, UIGestureRecognizerDelegate>{
    CGFloat count;
    CGFloat lastCount;
    
    CGRect mapFrameZoomOut;
    CGRect mapFrameZoomIn;
    
    BOOL canRotate;
    int annotationsViewCount;
    
    MKCoordinateRegion initialRegion;
    
    BOOL mapIsCenteredOnLocation;
    
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, assign) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) UIImageView *compass;
@property (nonatomic, retain) MKPolyline *polyline;

- (void)refreshWithNewPoints:(NSArray *)mapPoints;
- (void)addPoints:(NSArray *)mapPoints;
- (void)addPoint:(PlaceAnnotation *)mapPoint;

- (void)clear;

- (void)centerOnLocation:(CLLocation *)location;

@end
