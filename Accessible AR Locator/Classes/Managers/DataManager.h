//
//  DataManager.h
//  Accessible AR Locator
//
//  Created by QuickBlox developers on 04.05.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

#define maxPopularFriends 40

@interface DataManager : NSObject{
    // Core Data
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
}

// FB access
@property (nonatomic, retain) NSString				*accessToken;
@property (nonatomic, retain) NSDate				*expirationDate;

// current User
@property (nonatomic, retain) QBUUser				*currentQBUser;
@property (nonatomic, retain) NSMutableDictionary	*currentFBUser;
@property (nonatomic, retain) NSString				*currentFBUserId;

// Core Data
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (DataManager *) shared;

- (void)clearCache;

#pragma mark -
#pragma mark First switch All/Friends

- (BOOL)isFirstStartApp;
- (void)setFirstStartApp:(BOOL)firstStartApp;


#pragma mark -
#pragma mark Core Data api

-(NSArray *)mapARPointsFromStorage;
-(void)addMapARPointsToStorage:(NSArray *)points;
-(void)addMapARPointToStorage:(id)point; 

-(void) deleteAllObjects: (NSString *) entityDescription  context:(NSManagedObjectContext *)ctx;

@end
