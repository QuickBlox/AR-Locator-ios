//
//  PlaceAnnotation.m
//  Accessible AR Locator
//
//  Created by QuickBlox developers on 3/28/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "PlaceAnnotation.h"
#import "Macro.h"

@implementation PlaceAnnotation

@synthesize placeTitle, placeAddress, coordinate, createdAt, geoDataID, qbPlaceID, distance;

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super init])
	{
        DESERIALIZE_OBJECT(placeTitle, aDecoder);
        DESERIALIZE_OBJECT(placeAddress, aDecoder);
        DESERIALIZE_DOUBLE(coordinate.latitude, aDecoder);
        DESERIALIZE_DOUBLE(coordinate.longitude, aDecoder);
        DESERIALIZE_OBJECT(createdAt, aDecoder);
        
        DESERIALIZE_INT(geoDataID, aDecoder);
        DESERIALIZE_INT(qbPlaceID, aDecoder);
        
        DESERIALIZE_INT(distance, aDecoder);
        
	}
	
	return self;
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    SERIALIZE_OBJECT(placeTitle, aCoder);
    SERIALIZE_OBJECT(placeAddress, aCoder);
    SERIALIZE_DOUBLE(coordinate.latitude, aCoder);
    SERIALIZE_DOUBLE(coordinate.longitude, aCoder);
    SERIALIZE_OBJECT(createdAt, aCoder);
    
    SERIALIZE_INT(geoDataID, aCoder);
    SERIALIZE_INT(qbPlaceID, aCoder);
    
    SERIALIZE_INT(distance, aCoder);

}

- (void)dealloc
{
    
    [placeTitle release];
    [placeAddress release];
    [createdAt release];
    
    [super dealloc];
}

- (NSString *)description{
    
    NSString *desc = [NSString stringWithFormat:
                      @"%@\
                      \n\tplaceTitle:%@\
                      \n\tplaceAddress:%@\
                      \n\tqbPlaceID:%u\
                      \n\tgeoDataID:%d\
                      \n\tcreatedAt:%@",
                      
                      [super description],
                      placeTitle,
                      placeAddress,
                      qbPlaceID,
                      geoDataID,
                      createdAt];
    
    return desc;
}

#pragma mark -
#pragma mark NSCopying

-(id)copyWithZone:(NSZone *)zone
{
    PlaceAnnotation *copy = [[[self class] allocWithZone:zone] init];
    
    copy.placeTitle         = [[self.placeTitle copyWithZone:zone] autorelease];
    copy.placeAddress       = [[self.placeAddress copyWithZone:zone] autorelease];
    copy.coordinate         = self.coordinate;
    copy.createdAt          = [[self.createdAt copyWithZone:zone] autorelease];
    
    copy.geoDataID          = self.geoDataID;
    copy.qbPlaceID          = self.qbPlaceID;
    
    copy.distance           = self.distance;
    
    return copy;
}

@end
