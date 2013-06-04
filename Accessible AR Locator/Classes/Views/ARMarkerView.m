//
//  ARMarkerView.m
//  Accessible AR Locator
//
//  Created by QuickBlox developers on 3/26/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "ARMarkerView.h"

#define markerWidth 114
#define markerHeight 40

@implementation ARMarkerView

@synthesize target;
@synthesize action;
@synthesize distanceLabel, placeTitle, placeAddress, placeAnnotation;
@synthesize distance;

- (id)initWithGeoPoint:(PlaceAnnotation *)_placeAnnotation{
    	
	CGRect theFrame = CGRectMake(0, 0, markerWidth, markerHeight);
	
	if ((self = [super initWithFrame:theFrame])) {
        [self setBackgroundColor:[UIColor clearColor]];
        
        // save user annotation
        self.placeAnnotation = _placeAnnotation;
        
        [self setUserInteractionEnabled:YES];
        
        // bg view for user name & status & photo
        //
        UIImageView *container = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, markerWidth, markerHeight)];
		[container.layer setBorderColor:[[UIColor whiteColor] CGColor]];
		[container.layer setBorderWidth:1.0];
        
		[container setImage:[UIImage imageNamed:@"Marker.png"]];
        
        container.layer.cornerRadius = 2;
        container.clipsToBounds = YES;
        [container setBackgroundColor:[UIColor clearColor]];
        [self addSubview:container];
        [container release];
        
        UIImageView *imgLogo = [[UIImageView alloc] init];
        [imgLogo setFrame:CGRectMake(5, 5, 32, 32)];
        [imgLogo setImage:[UIImage imageNamed:@"barclays.png"] ];
        [container addSubview: imgLogo];
        [imgLogo release];
        
        // add placeTitle
        //
        placeTitle = [[UILabel alloc] initWithFrame:CGRectMake(42, 0, container.frame.size.width-43, container.frame.size.height/2)];
        [placeTitle setBackgroundColor:[UIColor clearColor]];
        [placeTitle setText:_placeAnnotation.placeTitle];
        [placeTitle setFont:[UIFont boldSystemFontOfSize:11]];
        [placeTitle setTextColor:[UIColor whiteColor]];
        [container addSubview:placeTitle];
        [placeTitle release];
        
        placeAddress = [[UILabel alloc] initWithFrame:CGRectMake(42, container.frame.size.height/2, container.frame.size.width-43, 15)];
        [placeAddress setBackgroundColor:[UIColor clearColor]];
        [placeAddress setText:_placeAnnotation.placeAddress];
        [placeAddress setFont:[UIFont systemFontOfSize:10]];
        [placeAddress setTextColor:[UIColor whiteColor]];
        [container addSubview:placeAddress];
        [placeAddress release];
        
        // add arrow
        //
        UIImageView *arrow = [[UIImageView alloc] init];
        [arrow setImage:[UIImage imageNamed:@"Marker_arrow.png"]];
        [arrow setFrame:CGRectMake(53, 40, 10, 8)];
        [self addSubview: arrow];
        [arrow release];
        
        
        // distance
		distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 55, markerWidth, 10)];
		[distanceLabel setBackgroundColor:[UIColor clearColor]];
		[distanceLabel setTextColor:[UIColor whiteColor]];
        [distanceLabel setFont:[UIFont systemFontOfSize:11]];
		[distanceLabel setTextAlignment:UITextAlignmentCenter];
        [self addSubview:distanceLabel];
        [distanceLabel release];
	}
	
    return self;
}

- (void)updateCoordinate:(CLLocationCoordinate2D)newCoordinate{
    placeAnnotation.coordinate = newCoordinate;
}

- (CLLocationDistance) updateDistance:(CLLocation *)newOriginLocation{
    CLLocation *pointLocation = [[CLLocation alloc] initWithLatitude:placeAnnotation.coordinate.latitude longitude:placeAnnotation.coordinate.longitude];
    CLLocationDistance _distance = [pointLocation distanceFromLocation:newOriginLocation];
    [pointLocation release];
    
    if(_distance < 0){
        [distanceLabel setHidden:YES];
    }else{
        if (_distance > 1000){
            distanceLabel.text = [NSString stringWithFormat:@"%.000f km", _distance/1000];
        }else {
            distanceLabel.text = [NSString stringWithFormat:@"%.000f m", _distance];
        }
        
        [distanceLabel setHidden:NO];
    }
    
    distance = _distance;
    
    return _distance;
}

- (double)distanceFrom:(CLLocationCoordinate2D)locationA to:(CLLocationCoordinate2D)locationB{
    double R = 6368500.0; // in meters
    
    double lat1 = locationA.latitude*M_PI/180.0;
    double lon1 = locationA.longitude*M_PI/180.0;
    double lat2 = locationB.latitude*M_PI/180.0;
    double lon2 = locationB.longitude*M_PI/180.0;
    
    return acos(sin(lat1) * sin(lat2) + 
                cos(lat1) * cos(lat2) *
                cos(lon2 - lon1)) * R;
}


// touch action
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if([target respondsToSelector:action]){
        [target performSelector:action withObject:self];
    }
}

- (void)dealloc {
    [placeAnnotation release];
    [super dealloc];
}

- (NSString *)description{
    return [NSString stringWithFormat:@"distance=%d", distance];
}

@end
