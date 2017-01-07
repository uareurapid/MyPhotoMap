//
//  BHAppDelegate.h
//  CollectionViewTutorial
//
//  Created by Bryan Hansen on 11/3/12.
//  Copyright (c) 2012 Bryan Hansen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import  <CoreLocation/CoreLocation.h>
#import <CoreData/CoreData.h>


@class SearchLocationViewController;
@class BHCollectionViewController;
@class PhotosMapViewController;

@interface PCAppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (retain, nonatomic) UINavigationController *navController;
//@property (strong, nonatomic) MainViewController *viewController;

@property (strong, nonatomic) BHCollectionViewController *collectionController;
@property (strong, nonatomic) PhotosMapViewController *mapViewController;

@property (strong, nonatomic) SearchLocationViewController *searchController;

@property (strong,nonatomic) CLLocationManager *locationManager;
@property (assign,nonatomic)CLLocationCoordinate2D location;


//CORE DATA
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@end
