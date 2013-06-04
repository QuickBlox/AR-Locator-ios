//
//  MapARViewController.m
//  Accessible AR Locator
//
//  Created by Alexey on 21.03.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "MapARViewController.h"
#import "ARMarkerView.h"

#import "QBPlaceModel.h"

#import "JSON.h"
#import "ARManager.h"
#import "DataManager.h"

@interface MapARViewController ()

- (void)processQBPlaces:(NSArray *)data;

- (void)addNewPointToMapAR:(PlaceAnnotation *)point;

@end

@implementation MapARViewController

@synthesize mapViewController, arViewController;
@synthesize segmentControl;
@synthesize mapPointsIDs;
@synthesize allMapPoints;
@synthesize selectedPlaceAnnotation;
@synthesize locationManager;
@synthesize initedFromCache;
@synthesize initState;
@synthesize currentLocation;

#pragma mark -
#pragma mark UIViewController life

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		
         // divice support AR
        if([ARManager deviceSupportsAR]){
            arViewController = [[AugmentedRealityController alloc] initWithViewFrame:CGRectMake(0, 45, 320, 415)];
            arViewController.delegate = self;
        }
        
        
        // Main storage
        allMapPoints = [[NSMutableArray alloc] init];
        
        // IDs
        mapPointsIDs = [[NSMutableArray alloc] init];
        

        // Loc manager
		locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        [locationManager startUpdatingLocation];
		
        
        isInitialized = NO;
        
        showAllUsers = NO;
        
    }
    return self;
}

- (void)dealloc
{
    
    self.mapViewController = nil;
    self.arViewController = nil;
    
    self.selectedPlaceAnnotation = nil;

    [allMapPoints release];
	
    [mapPointsIDs release];
    
    [locationManager release];
    
    self.currentLocation = nil;
     
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(IS_HEIGHT_GTE_568){
        CGRect mapChatARFrame = self.view.frame;
        mapChatARFrame.size.height += 88;
        [self.view setFrame:mapChatARFrame];
    }
    
	[locationManager startUpdatingLocation];
	
    // AR/Map segment
    if(![self.navigationItem.titleView isKindOfClass:UISegmentedControl.class]){
        NSArray *segments;
        if([ARManager deviceSupportsAR]){
            segments = [NSArray arrayWithObjects:NSLocalizedString(@"Map", nil), 
                                                    NSLocalizedString(@"Radar", nil), nil];
        }else{
            segments = [NSArray arrayWithObjects:NSLocalizedString(@"Map", nil), nil];
        }
        segmentControl = [[UISegmentedControl alloc] initWithItems:segments];
        [segmentControl setSegmentedControlStyle:UISegmentedControlStyleBar];
        [segmentControl setFrame:CGRectMake(20, 7, 280, 30)];
        [segmentControl addTarget:self action:@selector(segmentValueDidChanged:) forControlEvents:UIControlEventValueChanged];
		self.navigationItem.titleView = segmentControl;
        [segmentControl release];
    }
        
    // map delefates
    mapViewController.delegate = self;
    
}

- (void)initializeMap {

    if(!isInitialized){
        
        self.initState = 0;
        
        // show ar/map
        [segmentControl setSelectedSegmentIndex:0];
        [self segmentValueDidChanged:segmentControl];
        
        
        // get data from QuickBlox
        [self getQBGeodatas];
        
        
        isInitialized = YES;
        
        
    }

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
    [self initializeMap];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark AR/Map/Chat

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    self.currentLocation = newLocation;
    
    [self.mapViewController centerOnLocation:newLocation];
    
}

- (void)segmentValueDidChanged:(id)sender{
    switch (segmentControl.selectedSegmentIndex) {
            // show Map
        case 0:
            [self showMap];
            
            break;
            
            // show Radar
        case 1:
            
            [self showRadar];
            
            break;
            
            
        default:
            break;
    }
    
    // move wheel to front
    if(activityIndicator){
        [self.view bringSubviewToFront:activityIndicator];
    }
    //
    // move all/friends switch to front
    [self.view bringSubviewToFront:buttonNearest];
    
}


- (void)showRadar
{
    if([arViewController.view superview] == nil)
	{
        [self.view addSubview:arViewController.view];
        if(IS_HEIGHT_GTE_568){
            [arViewController.view setFrame:CGRectMake(0, 0, 320, 524)];
        }else{
            [arViewController.view setFrame:CGRectMake(0, 0, 320, 436)];
        }
    
    }
    [mapViewController.view removeFromSuperview];
    
    // start AR
    [arViewController displayAR];
}

- (void)showMap{
	
    if([mapViewController.view superview] == nil){
        [self.view addSubview:mapViewController.view];
    }
    [arViewController.view removeFromSuperview];
    
    // stop AR
    [arViewController dissmisAR];
}


- (void) showWorld{
    // notify controllers
    [mapViewController refreshWithNewPoints:self.allMapPoints];
    [arViewController refreshWithNewPoints:self.allMapPoints];
}

- (void)showActivity {
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicator.center = self.view.center;
    activityIndicator.tag = 1101;
    [self.view addSubview:activityIndicator];
    [activityIndicator startAnimating];
    
}

- (void)hideActivity {
    
    [activityIndicator removeFromSuperview];
    activityIndicator = nil;
}

#pragma mark -
#pragma mark Data requests

- (void)getQBGeodatas
{
    
    // get map/ar points from cash
    NSDate *lastPointDate = nil;
    NSArray *cashedMapARPoints = [[DataManager shared] mapARPointsFromStorage];
    if([cashedMapARPoints count] > 0){
        for(QBPlaceModel *mapARCashedPoint in cashedMapARPoints){
            if(lastPointDate == nil){
                lastPointDate = ((PlaceAnnotation *)mapARCashedPoint.body).createdAt;
            }
            [self.allMapPoints addObject:mapARCashedPoint.body];
            [self.mapPointsIDs addObject:[NSString stringWithFormat:@"%d", ((PlaceAnnotation *)mapARCashedPoint.body).geoDataID]];
        }
    }
    
    // If we have info from cashe - show them
    if([self.allMapPoints count] > 0){
        [self showWorld];
        
        initedFromCache = YES;
        
    }else{
        
        // show progress indicator
        [self showActivity];

    }
    
    // get points for map
    
    PagedRequest *pagedRequest = [PagedRequest request];
    pagedRequest.perPage = kGetGeoDataCount; // Pins limit for each page
    pagedRequest.page = 1;
    
 
    [QBLocation placesWithPagedRequest:pagedRequest delegate:self];
	
}

// get new points from QuickBlox Location
- (void) checkForNewPoints:(NSTimer *) timer{
    /*
	QBLGeoDataGetRequest *searchRequest = [[QBLGeoDataGetRequest alloc] init];
	searchRequest.status = YES;
    searchRequest.sortBy = GeoDataSortByKindCreatedAt;
    searchRequest.sortAsc = 1;
    searchRequest.perPage = 50;
    searchRequest.minCreatedAt = ((UserAnnotation *)[self lastChatMessage:YES]).createdAt;
	[QBLocation geoDataWithRequest:searchRequest delegate:self];
	[searchRequest release];
     */
}

/*
 Add new annotation to map,ar
 */

- (void)addNewPointToMapAR:(PlaceAnnotation *)point {
    
    [self.allMapPoints addObject:point];
    
    if(point.geoDataID != -1){
        [self.mapPointsIDs addObject:[NSString stringWithFormat:@"%d", point.geoDataID]];
    }

    [mapViewController addPoint:point];
    [arViewController addPoint:point];
    
    // Save to cache
    //
    [[DataManager shared] addMapARPointToStorage:point];

}

- (void)endOfRetrieveInitialData{

    // hide wheel
    [self hideActivity];
    
    buttonNearest.enabled = YES;
    
}

#pragma mark-
#pragma mark Helpers

// convert map array of QBLGeoData objects to UserAnnotations a
- (void)processQBPlaces:(NSArray *)data {

    NSArray *qbPoints = data;
    
    CLLocationCoordinate2D coordinate;
    int index = 0;
    
    NSMutableArray *mapPointsMutable = [qbPoints mutableCopy];
    
    // look through array for geodatas
    for (QBLPlace *geodata in qbPoints)
    {
    
        
        coordinate.latitude = geodata.latitude;
        coordinate.longitude = geodata.longitude;
        
        
        PlaceAnnotation *mapAnnotation = [[PlaceAnnotation alloc] init];
        mapAnnotation.qbPlaceID = geodata.ID;
        mapAnnotation.geoDataID = geodata.geoDataID;
        mapAnnotation.coordinate = coordinate;
        mapAnnotation.placeTitle = geodata.title;
        mapAnnotation.placeAddress = geodata.address;
        mapAnnotation.createdAt = geodata.createdAt;
        [mapPointsMutable replaceObjectAtIndex:index withObject:mapAnnotation];
        [mapAnnotation release];
        
        ++index;
        
        // show Point on Map/AR
        dispatch_async( dispatch_get_main_queue(), ^{
            [self addNewPointToMapAR:mapAnnotation];
        });
    }
    
    // update AR
    dispatch_async( dispatch_get_main_queue(), ^{
        [arViewController updateMarkersPositionsForCenterLocation:arViewController.centerLocation];
    });

    //
    // add to Storage
    [[DataManager shared] addMapARPointsToStorage:mapPointsMutable];
    
    [mapPointsMutable release];
    
    // all data was retrieved
    ++self.initState;
    NSLog(@"MAP INIT OK");
    if(self.initState == 1){
        dispatch_async( dispatch_get_main_queue(), ^{
            [self endOfRetrieveInitialData];
        });
    }
}

#pragma mark -
#pragma mark QB QBActionStatusDelegate

- (void)completedWithResult:(Result *)result {
    NSLog(@"completedWithResult");
    
    if ([result isKindOfClass:QBLPlacePagedResult.class]) {
        
        if (result.success && [result isKindOfClass:QBLPlacePagedResult.class]) {
            QBLPlacePagedResult *placesResult = (QBLPlacePagedResult *)result;
            NSLog(@"Places: %@", placesResult.places);
            
            if ([placesResult.places count] == 0){
                return;
            }
            
            NSMutableArray *geodataProcessed = [NSMutableArray array];
            
            for (QBLPlace *geodata in placesResult.places) {
                // skip if already exist
                if([self.mapPointsIDs containsObject:[NSString stringWithFormat:@"%d", geodata.geoDataID]]){
                    continue;
                }
                
                //add users with only nonzero coordinates
                if(geodata.latitude != 0 && geodata.longitude != 0){
                    
                    [geodataProcessed addObject:geodata];
                }
            }
            if([geodataProcessed count] == 0){
                
                [self endOfRetrieveInitialData];
                
                return;
            }
            
            [self processQBPlaces:geodataProcessed];

            
        } else {
            [self hideActivity];
        }
    
        
    }
    
}

#pragma mark -
#pragma mark Route

- (IBAction)showRoute {

    int minDistanceIndex = -1;
    double minDistance = 0;
    
    for (int i = 0; i < [self.allMapPoints count]; i++) {
        PlaceAnnotation *mapAnnotation = [self.allMapPoints objectAtIndex:i];
        
        CLLocation *pointLocation = [[CLLocation alloc] initWithLatitude:mapAnnotation.coordinate.latitude longitude:mapAnnotation.coordinate.longitude];
        CLLocationDistance distance = [pointLocation distanceFromLocation:self.currentLocation];
        [pointLocation release];
        
        if (minDistanceIndex < 0 || minDistance > distance) {
            
            minDistanceIndex = i;
            minDistance = distance;
            
        }
    }
    
    if (minDistanceIndex >= 0) {
        
        PlaceAnnotation *mapAnnotation = [self.allMapPoints objectAtIndex:minDistanceIndex];
        
        
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(mapAnnotation.coordinate.latitude, mapAnnotation.coordinate.longitude);
        
        //create MKMapItem out of coordinates
        MKPlacemark* placeMark = [[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil];
        MKMapItem* destination =  [[MKMapItem alloc] initWithPlacemark:placeMark];
        
        if([destination respondsToSelector:@selector(openInMapsWithLaunchOptions:)])
        {
            //using iOS6 native maps app
            [destination openInMapsWithLaunchOptions:@{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeWalking}];
             
        }
        else
        {
            //using iOS 5 which has the Google Maps application
            NSString* urlString = [NSString stringWithFormat: @"http://maps.google.com/maps?saddr=%f,%f&daddr=%f,%f&dirflg=w", self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude, coordinate.latitude, coordinate.longitude];
            
            NSString *escaped = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:escaped]];
        }

        
    }

}
// 48,014293   37,76959
@end
