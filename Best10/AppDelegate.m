//
//  AppDelegate.m
//  Best10
//
//  Created by Francois Chaubard on 12/26/13.
//  Copyright (c) 2013 Chaubard. All rights reserved.
//

#import "AppDelegate.h"
#import "DHSidebarViewController.h"
#import "BestFriendMapViewController.h"
#import "JSONFetcher.h"
#import "Friend+MKAnnotation.h"
#import "MyCLLocationManager.h"

@implementation AppDelegate

@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize backgroundManagedObjectContext = _backgroundManagedObjectContext;
@synthesize backgroundPersistentStoreCoordinator = _backgroundPersistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    /////////////////////////////////
    /// TAKE THIS OUT WHEN READY ////
    ////////////////////////////////
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"token"]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"111" forKey:@"token"];
    }
    

    // Parse setup
    [Parse setApplicationId:@"EuISCJmV7sb8VUR9gLELw9Fch9wbkhbUVdQwyHaX"
                  clientKey:@"AgVzA9fiXDv4JrHm0Kc9NkyQ9deZ85zpoOnvPCjC"];
    [PFImageView class];
    
    // Register for Push Notitications, if running iOS 8
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                 categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    } else {
        // Register for Push Notifications before iOS 8
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                         UIRemoteNotificationTypeAlert |
                                                         UIRemoteNotificationTypeSound)];
    }
    
    /*[application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|
     UIRemoteNotificationTypeAlert|
     UIRemoteNotificationTypeSound];*/
    // Parse Analytics
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];

    
    // if its being awoken in the background.. we dont need to do all this..
    if (UIApplicationStateBackground != application.applicationState && [PFUser currentUser]!=nil) {
        
    
        [self setUpDrawer:application];
        
    
    }else if ( [PFUser currentUser]==nil){
        
        [self walkThroughInitialSignUp:application];
        
    }
    return YES;

}


-(void)walkThroughInitialSignUp:(UIApplication *)application{
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    if(![[NSUserDefaults standardUserDefaults] objectForKey:@"current view controller"])
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"Signup" forKey:@"current view controller"];
    }
    
    UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Signup" bundle:nil];
    UIViewController* rootViewController = [mainStoryboard instantiateInitialViewController];
    
    
    self.window.rootViewController = rootViewController;
    
    [self.window makeKeyAndVisible];
    
}


-(void)setUpDrawer:(UIApplication *)application{
    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    if(![[NSUserDefaults standardUserDefaults] objectForKey:@"current view controller"])
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"Home Map" forKey:@"current view controller"];
    }
    
    UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController* rootViewController = [mainStoryboard instantiateInitialViewController];
    UIViewController* sidebarViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"SidebarViewController"];
    
    self.sidebarVC = [[DHSidebarViewController alloc] initWithRootViewController:rootViewController sidebarViewController:sidebarViewController];
    
    self.window.rootViewController = self.sidebarVC;
    
    [self.window makeKeyAndVisible];
    
    [self refreshUserData];
}

// More parse setup
- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
}


- (void) application:(UIApplication *)application
performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [self refreshUserData];
   
}


-(void)refreshUserData{
    // pull data from the server
    dispatch_queue_t transQueue = dispatch_queue_create("pull new data", NULL);
    dispatch_async(transQueue, ^{
        
        NSArray *friends = [JSONFetcher pullFriendsData];
        //NSArray *messages = [JSONFetcher pullChatData];
        
        
        
        //TRIED TO MAKE A BACKGROUND PERSISTANT STORE BUT IT WOULDNT LET ME
        /*
        // populate the database with updated friends
        [self.backgroundManagedObjectContext performBlock:^{
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Friend"];
            NSArray *oldfriends = [self.backgroundManagedObjectContext executeFetchRequest:request error:NULL];
            for (Friend* friend in oldfriends) {
                [self.backgroundManagedObjectContext deleteObject:friend];
            }
            //populate it with new ones
            for (NSDictionary *friend in friends) {
                [Friend friendWithData:friend inManagedObjectContext:self.backgroundManagedObjectContext];
            }
        }];
        
        [self saveContextBackground];
         
         */
        
        
        
        
        // populate the database with new chats

        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Friend"];
        NSArray *oldfriends = [self.managedObjectContext executeFetchRequest:request error:NULL];
        for (Friend* friend in oldfriends) {
            [self.managedObjectContext deleteObject:friend];
        }
        //populate it with new ones
        for (NSDictionary *friend in friends) {
            [Friend friendWithData:friend inManagedObjectContext:self.managedObjectContext];
        }
    
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //[self restPSCandMOCforMain];
            // populate the database with updated friends
           
            
        });
    });

}






- (DHSidebarViewController *)getSidebarVC{
    return self.sidebarVC;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}
- (void)saveContextBackground
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.backgroundManagedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectContext *)backgroundManagedObjectContext
{
    if (_backgroundManagedObjectContext != nil) {
        return _backgroundManagedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self backgroundPersistentStoreCoordinator];
    if (coordinator != nil) {
        _backgroundManagedObjectContext = [[NSManagedObjectContext alloc] init];
        [_backgroundManagedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _backgroundManagedObjectContext;
}


// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Best10" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Best10.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}


- (void)restPSCandMOCforMain
{
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Best10.sqlite"];

    NSError *error = nil;
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    _persistentStoreCoordinator = persistentStoreCoordinator;
    
    
    
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator:persistentStoreCoordinator];
    
    _managedObjectContext=managedObjectContext;
    
    
    
    
    
}



- (NSPersistentStoreCoordinator *)backgrounPersistentStoreCoordinator
{
    if (_backgroundPersistentStoreCoordinator != nil) {
        return _backgroundPersistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Best10.sqlite"];
    
    NSError *error = nil;
    _backgroundPersistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_backgroundPersistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _backgroundPersistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


-(NSArray *)getGerunds
{
    
    NSArray *gerunds = [[NSUserDefaults standardUserDefaults] objectForKey:@"gerunds"];
    
    if (!gerunds ) { // default values
        gerunds = @[ @"Eating",
                     @"Exercising",
                     @"Studying",
                     @"Raging",
                     @"Shopping",
                     @"Coffeeing",
                     @"Ghosting"];
        
        [[NSUserDefaults standardUserDefaults] setObject:gerunds forKey:@"gerunds"];
    }
    
    return gerunds;
}


-(NSString *)getUserToken
{
    
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
    
    if (!token ) {
        token = @"111";
        [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"token"];
    }
    
    return token;
}

- (NSString *)getUserActivity
{
    NSString *activity = [[NSUserDefaults standardUserDefaults] objectForKey:@"activity"];
    
    if (!activity ) {
        activity = @"";
        [[NSUserDefaults standardUserDefaults] setObject:activity forKey:@"activity"];
    }
    
    return activity;
}

- (NSString *)getUserDeviceToken
{
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
    
    if (!token ) {
        token = @"adsfa11asdadfsaa1";
        [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"token"];
    }
    
    return token;
}

- (NSString *)getUserCurrentViewController
{
    NSString *currentVC = [[NSUserDefaults standardUserDefaults] objectForKey:@"current view controller"];
    
    if (!currentVC ) {
        currentVC = @"Home Map";
        [[NSUserDefaults standardUserDefaults] setObject:currentVC forKey:@"current view controller"];
    }
    
    return currentVC;
}
- (MyCLLocationManager *)getLocationManager{
    return [MyCLLocationManager sharedSingleton];
}
- (CLLocation *)getUserCurrentLocation{
    return [MyCLLocationManager sharedSingleton].locationManager.location;
}



@end
