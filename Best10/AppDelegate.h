//
//  AppDelegate.h
//  Best10
//
//  Created by Francois Chaubard on 12/26/13.
//  Copyright (c) 2013 Chaubard. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DHSidebarViewController.h"
#import "MyCLLocationManager.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
//@property (strong, nonatomic) MSDynamicsDrawerViewController *dynamicsDrawerViewController;

@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectContext *backgroundManagedObjectContext;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *backgroundPersistentStoreCoordinator;

@property (strong,nonatomic) DHSidebarViewController *sidebarVC;


- (DHSidebarViewController *)getSidebarVC;
- (void)saveContext;
- (void)saveContextBackground;

- (void)refreshUserData;


- (NSURL *)applicationDocumentsDirectory;
- (NSArray *)getGerunds;
- (NSString *)getUserToken;
- (NSString *)getUserActivity;
- (NSString *)getUserDeviceToken;
- (NSString *)getUserCurrentViewController;
- (MyCLLocationManager *)getLocationManager;
- (CLLocation *)getUserCurrentLocation;
- (void)updateUserStatus:(NSUInteger)gerundNumber;
- (void)setUpDrawer:(UIApplication *)application;

@end
