//
//  MapARViewController.h
//  Accessible AR Locator
//
//  Created by Alexey on 21.03.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "MapViewController.h"
#import "AugmentedRealityController.h"

#define kGetGeoDataCount 100

@class ChatViewController;
@class MapViewController;

@interface MapARViewController : UIViewController <QBActionStatusDelegate, UIActionSheetDelegate, CLLocationManagerDelegate>{
    
    short numberOfCheckinsRetrieved;
    
    BOOL isInitialized;
    
    UIActivityIndicatorView *activityIndicator;
    
    BOOL showAllUsers;
    
    IBOutlet UIButton *buttonNearest;
    
}

@property (assign) NSMutableArray* allMapPoints;

@property (assign) NSMutableArray *mapPointsIDs;

@property (nonatomic, retain) CLLocationManager *locationManager;

@property (retain) IBOutlet MapViewController *mapViewController;
@property (retain) AugmentedRealityController *arViewController;

@property (nonatomic, assign) UISegmentedControl *segmentControl;

@property (retain) PlaceAnnotation *selectedPlaceAnnotation;

@property (nonatomic, assign) BOOL initedFromCache;

@property (assign) short initState;

@property (nonatomic, retain) CLLocation *currentLocation;


- (void)initializeMap;

- (void)segmentValueDidChanged:(id)sender;
- (void)showRadar;
- (void)showMap;


//- (void)findRoute;
- (IBAction)showRoute;

@end
