//
//  BHAppDelegate.m
//  CollectionViewTutorial
//
//  Created by Bryan Hansen on 11/3/12.
//  Copyright (c) 2012 Bryan Hansen. All rights reserved.
//

#import "PCAppDelegate.h"
#import "PhotosMapViewController.h"
#import "BHCollectionViewController.h"
#import "MYAlbumViewController.h"
#import "SearchLocationViewController.h"

@implementation PCAppDelegate

@synthesize navController,collectionController,mapViewController;
@synthesize locationManager,location;
@synthesize managedObjectContext, managedObjectModel,persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    self.mapViewController = [[PhotosMapViewController alloc] initWithNibName:@"PhotosMapViewController" bundle:nil];
    self.collectionController = [[BHCollectionViewController alloc] initWithNibName:@"BHCollectionViewController" bundle:nil];
    self.collectionController.albumViewController  = [[MYAlbumViewController alloc] initWithNibName:@"MYAlbumCollectionViewController" bundle:nil];
    
    self.searchController = [[SearchLocationViewController alloc] initWithNibName:@"SearchLocationViewController" bundle:nil];

 
    //add the map reference on both controllers
    self.collectionController.mapViewController = mapViewController;
    self.collectionController.albumViewController.mapViewController = mapViewController;
    
    navController = [[UINavigationController alloc] init];
    [navController pushViewController: collectionController animated:NO];
    

    //init the tab bar
    UITabBarController * tabBarController = [[UITabBarController alloc ] init];
    [tabBarController setViewControllers: [NSArray arrayWithObjects:navController,mapViewController, nil] ];

    
    for(UIViewController *tab in  tabBarController.viewControllers)
    {
        [tab.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor blackColor], NSForegroundColorAttributeName,
                                                           [UIFont fontWithName:@"AmericanTypewriter" size:30.0f], NSFontAttributeName,
                                                           nil] forState:UIControlStateSelected];
    }
    //TODO CHECK
    self.collectionController.managedObjectContext = [self managedObjectContext];
    
    //set the navigation controller as the root view
    self.window.rootViewController = tabBarController;
    
  
    [self.window makeKeyAndVisible];
    
    locationManager = [[CLLocationManager alloc]init];
    [locationManager setDelegate:self];
    //if ios > 8
    [locationManager requestAlwaysAuthorization];
    [locationManager startMonitoringSignificantLocationChanges];
    [locationManager startUpdatingLocation];
    
    
    return YES;
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
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

//location maganer delegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Unable to get Location: Got error %@",error);
}

//location manager delegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    //should be only one
    CLLocation *elem = [locations objectAtIndex:locations.count-1];
    location =  elem.coordinate;
    collectionController.location = elem;
    collectionController.albumViewController.location = elem;
   // NSLog(@"did update locations: %@",elem);
}

//- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    //http://stackoverflow.com/questions/12602463/didupdatelocations-instead-of-didupdatetolocation
  //  CLLocation *newLocation = (CLLocation *)[locations lastObject];
  //  location = newLocation.coordinate;
  //  collectionController.location = newLocation;
  //  collectionController.albumViewController.location = newLocation;
//}

//deprecated;
//- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
  //  location =  newLocation.coordinate;
  //  collectionController.location = newLocation;
  //  collectionController.albumViewController.location = newLocation;
    //NSLog(@"did update didUpdateToLocation: %@",newLocation);
//}

#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store
 coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
    
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in
 application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
    
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
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
    
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self loadApplicationDocumentsDirectory]
                                               stringByAppendingPathComponent: @"mystore.sqlite"]];
    
    NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                  initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                  configuration:nil URL:storeUrl options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should
         not use this function in a shipping application, although it may be useful during
         development. If it is not possible to recover from the error, display an alert panel that
         instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible
         * The schema for the persistent store is incompatible with current managed object
         model
         Check the error message to determine what the actual problem was.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return persistentStoreCoordinator;
}
//load the application documents path
-(NSString*) loadApplicationDocumentsDirectory {
    
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [searchPaths objectAtIndex:0];
    return documentPath;
}
@end
