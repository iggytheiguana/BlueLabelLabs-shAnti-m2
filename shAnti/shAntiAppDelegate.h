//
//  shAntiAppDelegate.h
//  shAnti
//
//  Created by Jordan Gurrieri on 4/23/12.
//  Copyright (c) 2012 Blue Label Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Facebook.h"
#import "AuthenticationManager.h"
#import "ApplicationSettingsManager.h"

@class shAntiViewController;

@interface shAntiAppDelegate : UIResponder <UIApplicationDelegate>
{
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSString* m_deviceToken;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain)           Facebook    *facebook;
@property (nonatomic, retain) AuthenticationManager*    authenticationManager;
@property (nonatomic, retain) ApplicationSettingsManager*   applicationSettingsManager;
@property (nonatomic, retain) NSString* deviceToken;

@property (strong, nonatomic) shAntiViewController *viewController;



- (NSURL *)applicationDocumentsDirectory;
- (NSString*) getImageCacheStorageDirectory;

@end
