//
//  SearchLocationViewController.h
//  CollectionViewTutorial
//
//  Created by Paulo Cristo on 6/11/13.
//  Copyright (c) 2013 Bryan Hansen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyGPSPosition.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AssetsLibrary/ALAssetRepresentation.h>
#import "LocationDataModel.h"

#define GOOGLE_KEY_DATA_FORMATED_ADDRESS  @"formatted_address"
#define GOOGLE_KEY_DATA_GEOMETRY          @"geometry"
//these are the parameters names
//coordinates
#define PARAMETER_LONGITUDE  @"lng"
#define PARAMETER_LATITUDE  @"lat"

//location
#define PARAMETER_LOCATION @"location"

@class PhotosMapViewController;

typedef void (^ALAssetsLibraryAssetForURLResultBlock)(ALAsset *asset);
typedef void (^ALAssetsLibraryAccessFailureBlock)(NSError *error);

@interface SearchLocationViewController : UIViewController <UISearchBarDelegate>
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) IBOutlet UITableView *placesTableView;
@property (strong, nonatomic) NSMutableArray *placesList;

//the selected image
@property (strong, nonatomic) UIImage *image;
@property (copy, nonatomic) NSURL *assetURL;

//The managed object context is the connection between your code and the data store. All of the operations you will execute for Core Data do so against the managed object context.
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSMutableArray *locationEntitiesArray;
//further reading here: http://mobile.tutsplus.com/tutorials/iphone/iphone-core-data/

@property (strong,nonatomic) PhotosMapViewController *mapView;

-(void)saveLocationRecord:(MyGPSPosition*)location;
- (void)fetchLocationRecords;
-(void) loadAssetInfoFromDataModel:(LocationDataModel*)model;

@end
