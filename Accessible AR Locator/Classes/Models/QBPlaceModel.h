//
//  QBPlaceModel.h
//  AARLocator
//
//  Created by Pavel Belevtsev on 01.06.13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface QBPlaceModel : NSManagedObject

@property (nonatomic, retain) id body;
@property (nonatomic, retain) NSNumber * qbPlaceID;
@property (nonatomic, retain) NSNumber * timestamp;

@end
