//
//  MapPinView.m
//  Accessible AR Locator
//
//  Created by QuickBlox developers on 3/28/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "MapMarkerView.h"

#define markerWidth 100
#define markerHeight 76

@implementation MapMarkerView

@synthesize placeTitle, placeAddress, annotation, userNameBG;
@synthesize target, action;

-(id)initWithAnnotation:(id<MKAnnotation>)_annotation reuseIdentifier:(NSString *)reuseIdentifier{
    
    if ((self = [super initWithAnnotation:_annotation reuseIdentifier:reuseIdentifier])) {
        
        self.frame = CGRectMake(0, 0, markerWidth, markerHeight*2);
        
        //self.frame = CGRectMake(0, 0, markerWidth, markerHeight*2);
        // save annotation
        //
        annotation = (PlaceAnnotation *)[_annotation retain];

        
        // bg view for user name & status & photo
        //
        container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, markerWidth, markerHeight - 8)];
        container.clipsToBounds = YES;
        [container setBackgroundColor:[UIColor clearColor]];
        [self addSubview:container];
        [container release];
        
        UIImageView *imgLogo = [[UIImageView alloc] init];
        [imgLogo setFrame:CGRectMake(32, 10, 36, 36)];
        [imgLogo setImage:[UIImage imageNamed:@"barclays.png"] ];
        [container addSubview: imgLogo];
        [imgLogo release];
        
        //add user marker
        userNameBG = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"radarMarkerTitle.png"]];
        [userNameBG setFrame:CGRectMake(10, 48, userNameBG.frame.size.width, userNameBG.frame.size.height)];
        
        [container addSubview: userNameBG];
        [userNameBG release];
        
        // add Place Title
        placeTitle = [[UILabel alloc] initWithFrame:CGRectMake(2, 0, userNameBG.frame.size.width-3, 10)];
        [placeTitle setBackgroundColor:[UIColor clearColor]];
        [placeTitle setText:annotation.placeTitle];
        [placeTitle setFont:[UIFont boldSystemFontOfSize:9]];
        [placeTitle setTextColor:[UIColor whiteColor]];
        [userNameBG addSubview:placeTitle];
        [placeTitle release];
        
        // add Place Address
        placeAddress = [[UILabel alloc] initWithFrame:CGRectMake(2, 9, userNameBG.frame.size.width-3, 10)];
        [placeAddress setBackgroundColor:[UIColor clearColor]];
        [placeAddress setText:annotation.placeAddress];
        [placeAddress setFont:[UIFont systemFontOfSize:9]];
        [placeAddress setTextColor:[UIColor whiteColor]];
        [userNameBG addSubview:placeAddress];
        [placeAddress release];

        
        // add arrow
        //
        UIImageView *arrow = [[UIImageView alloc] init];
        [arrow setImage:[UIImage imageNamed:@"radarMarkerArrow.png"]];
        [arrow setFrame:CGRectMake(45, 68, 10, 8)];
        [self addSubview: arrow];
        [arrow release];

        
        //[self updateContainer:_annotation];
    }
    
    return self;
}

- (void)updateCoordinate:(CLLocationCoordinate2D)newCoordinate{
    annotation.coordinate = newCoordinate;
}

- (void)updateAnnotation:(PlaceAnnotation *)_annotation{
    
    //[self updateContainer:_annotation];
    [annotation release];
    annotation = [_annotation retain];
    
    [placeTitle setText:_annotation.placeTitle];
    
}

// touch action
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch* touch = [[touches allObjects] objectAtIndex:0];
	CGPoint location = [touch locationInView:self];
	CGRect rect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height/2);
	
	if (CGRectContainsPoint(rect, location))
	{
		if([target respondsToSelector:action])
		{
			[target performSelector:action withObject:self];
		}
	}
}

- (void)dealloc
{
    [annotation release];
    [super dealloc];
}

@end
