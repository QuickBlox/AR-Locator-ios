//
//  DataManager.m
//  Accessible AR Locator
//
//  Created by QuickBlox developers on 04.05.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "DataManager.h"
#import "PlaceAnnotation.h"

#import "QBPlaceModel.h"


#define qbCheckinsFetchLimit 150
#define fbCheckinsFetchLimit 50
#define qbChatMessagesFetchLimit 40

#define QBPlaceModelEntity @"QBPlaceModel"


@implementation DataManager

static DataManager *instance = nil;

@synthesize accessToken, expirationDate;

@synthesize currentQBUser;
@synthesize currentFBUser;
@synthesize currentFBUserId;

+ (DataManager *)shared {
	@synchronized (self) {
		if (instance == nil){ 
            instance = [[self alloc] init];
        }
	}
	
	return instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(void) dealloc 
{
    [accessToken release];
	[expirationDate release];
    
	[currentFBUser release];
	[currentQBUser release];
    [currentFBUserId release];
    
    
    
    [managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];
    	
	[super dealloc];
}

#pragma mark -
#pragma mark Core Data core

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [NSManagedObjectContext new];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
        [managedObjectContext setMergePolicy:NSOverwriteMergePolicy];
        [managedObjectContext setUndoManager:nil];
    }
    return managedObjectContext;
}


/**
 Returns the thread safe managed object context for the application.
 */
- (NSManagedObjectContext *)threadSafeContext {
    NSManagedObjectContext * context = nil;
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    
    if (coordinator != nil) {
        context = [[[NSManagedObjectContext alloc] init] autorelease];
        [context setPersistentStoreCoordinator:coordinator];
        [context setMergePolicy:NSOverwriteMergePolicy];
        [context setUndoManager:nil];
    }
    
    return context;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    
	/*
	 Set up the store.
	 */
	NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"aarlocatordata.bin"]];
    
	NSError *error;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 
		 Typical reasons for an error here include:
		 * The persistent store is not accessible
		 * The schema for the persistent store is incompatible with current managed object model
		 Check the error message to determine what the actual problem was.
		 */
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
    }
    
    return persistentStoreCoordinator;
}

#pragma mark -
#pragma mark First switch All/Friends

- (BOOL)isFirstStartApp{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *firstStartApp = [defaults objectForKey:@"kFirstSwitchPlaces"];
    if(firstStartApp == nil){
        return YES;
    }
    return  [firstStartApp boolValue];
}

- (void)setFirstStartApp:(BOOL)firstStartApp{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithBool:firstStartApp] forKey:@"kFirstSwitchPlaces"];
    [defaults synchronize];
}


#pragma mark -
#pragma mark Core Data: general

- (void) deleteAllObjects: (NSString *) entityDescription  context:(NSManagedObjectContext *)ctx {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityDescription inManagedObjectContext:ctx];
    [fetchRequest setEntity:entity];
    
    
    NSError *error;
    NSArray *items = [ctx executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    
    
    for (NSManagedObject *managedObject in items) {
        [ctx deleteObject:managedObject];
    }
    if (![ctx save:&error]) {
        NSLog(@"CoreData: deleting %@ - error:%@",entityDescription,error);
    }
}

- (void)clearCache{
    NSManagedObjectContext *ctx = [self threadSafeContext];
    
    [self deleteAllObjects:QBPlaceModelEntity context:ctx];

}

#pragma mark -
#pragma mark Core Data: QB Checkins

-(void)addMapARPointsToStorage:(NSArray *)points{
    NSManagedObjectContext *ctx = [self threadSafeContext];
    for(PlaceAnnotation *point in points){
        [self addMapARPointToStorage:point context:ctx];
    }
}
//
-(void)addMapARPointToStorage:(PlaceAnnotation *)point{
    NSManagedObjectContext *ctx = [self threadSafeContext];
    [self addMapARPointToStorage:point context:ctx];
}

-(void)addMapARPointToStorage:(PlaceAnnotation *)point context:(NSManagedObjectContext *)ctx{
    
    
    // Check if exist
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:QBPlaceModelEntity
											  inManagedObjectContext:ctx];
    [fetchRequest setEntity:entity];
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"qbPlaceID == %i", point.qbPlaceID]];
	NSArray *results = [ctx executeFetchRequest:fetchRequest error:nil];
    [fetchRequest release];
    
    QBPlaceModel *pointObject = nil;
    
    // Update
    if (nil != results && [results count] > 0) {
        pointObject = (QBPlaceModel *)[results objectAtIndex:0];
        pointObject.body = point;
        pointObject.timestamp = [NSNumber numberWithInt:[point.createdAt timeIntervalSince1970]];
        
        // Insert
    } else {
        pointObject = (QBPlaceModel *)[NSEntityDescription insertNewObjectForEntityForName:QBPlaceModelEntity
                                                                      inManagedObjectContext:ctx];
        pointObject.body = point;
        pointObject.qbPlaceID = [NSNumber numberWithInt:point.qbPlaceID];
        pointObject.timestamp = [NSNumber numberWithInt:[point.createdAt timeIntervalSince1970]];

    }
    
    NSError *error = nil;
    [ctx save:&error];
    if(error){
        NSLog(@"CoreData: addMapARPointToStorage error=%@", error);
    }
     
}
//
-(NSArray *)mapARPointsFromStorage{
     NSManagedObjectContext *ctx = [self threadSafeContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:QBPlaceModelEntity
                                                         inManagedObjectContext:ctx];
    
    [fetchRequest setEntity:entityDescription];
    [fetchRequest setFetchLimit:qbCheckinsFetchLimit];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSError *error;
    NSArray* results = [ctx executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    
    //select places with nonzero coordinates
    NSMutableArray *result = [NSMutableArray array];
    for(QBPlaceModel *model in results){
        if(((PlaceAnnotation *)model.body).coordinate.latitude != 0 && ((PlaceAnnotation *)model.body).coordinate.longitude != 0){
            [result addObject:model];
        }
    }
    
    //select only 50 last places
    while([result count] > 50){
            [result removeLastObject];
    }
    
    return result;
}

#pragma mark -
#pragma mark Application's documents directory

/**
 Returns the path to the application's documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


@end
