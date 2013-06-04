//
//  UserAnnotation.h
//  Accessible AR Locator
//
//  Created by Pavel Belevtsev on 03.06.13.
//  Copyright (c) 2013 Injoit. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface UserAnnotation : NSObject <MKAnnotation> {
    NSString *_title;
    NSString *_subtitle;
    
    CLLocationCoordinate2D _coordinate;
}

// Getters and setters
- (void)setTitle:(NSString *)title;
- (void)setSubtitle:(NSString *)subtitle;

@end
