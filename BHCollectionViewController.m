//
//  BHCollectionViewController.m
//  CollectionViewTutorial
//
//  Created by Bryan Hansen on 11/3/12.
//  Copyright (c) 2012 Bryan Hansen. All rights reserved.
//

#import "BHCollectionViewController.h"

#import "BHAlbumPhotoCell.h"
#import "BHAlbumTitleReusableView.h"
#import "MYAlbumViewController.h"
#import "SearchLocationViewController.h"
#import "PhotosMapViewController.h"


@interface BHCollectionViewController ()

@property NSInteger COUNTER;

@end

@implementation BHCollectionViewController

@synthesize albums,albumViewController;
@synthesize assetsURLs;
@synthesize tabBarController;
@synthesize numExistingAlbums;
@synthesize albumTextField;
@synthesize addAlbumButton,navController;
@synthesize mapViewController;
@synthesize location;
@synthesize databaseRecords;
@synthesize albumsYears;
@synthesize managedObjectContext, isLoaded;



- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle {
    self = [super initWithNibName:nibName bundle:nibBundle];
    if(self) {
        isLoaded = false;
        albums = [NSMutableArray array];
        assetsURLs = [[NSMutableArray alloc] init];
        albumsYears = [[NSMutableArray alloc] init];
        
        self.title = @"Your Albums";
        
        //addAlbumButton = [[UIBarButtonItem alloc] initWithTitle:@"Settings"
        //                  style:UIBarButtonItemStyleDone target:self action:@selector(settingsClicked:)];
        
        //self.navigationItem.rightBarButtonItem = addAlbumButton;
        
        
        
        UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithTitle:@"Add"
                                                          style:UIBarButtonItemStyleDone target:self action:@selector(addAlbumClicked:)];
        
 
       
        self.navigationItem.rightBarButtonItem = add;//leftBarButtonItem
        
        
        
        databaseRecords = [[NSMutableArray alloc] init];
        
        self.tabBarItem.image = [UIImage imageNamed:@"photos.png"];
        
        
       
      
    }
    return self;
    
}


#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *patternImage = [UIImage imageNamed:@"concrete_wall"];
    self.collectionView.backgroundColor = [UIColor colorWithPatternImage:patternImage];
    numExistingAlbums=0;
    self.COUNTER = 0;
    
    [self.collectionView registerClass:[BHAlbumPhotoCell class]
            forCellWithReuseIdentifier:PhotoCellIdentifier];
    [self.collectionView registerClass:[BHAlbumTitleReusableView class]
            forSupplementaryViewOfKind:BHPhotoAlbumLayoutAlbumTitleKind
                   withReuseIdentifier:AlbumTitleIdentifier];
    
    self.thumbnailQueue = [[NSOperationQueue alloc] init];
    self.thumbnailQueue.maxConcurrentOperationCount = 3;
    
    
    
    
    self.existingAlbumsNames = [[NSMutableArray alloc] init];
    
    //clear annotations
    [mapViewController removeAnnotations];
    
    
    
}

-(void) viewDidAppear:(BOOL)animated {
    
    if(!self.isLoaded) {
        
        self.isLoaded = true;
        
        [self checkAuthorizationStatus];
        
        //and now load all existing data from database
        [self fetchLocationRecordsFromDatabase];
    }
    
}
//will also read albums and photos data
-(void) checkAuthorizationStatus {
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];

    if (status == PHAuthorizationStatusAuthorized) {
         // Access has been granted.
        [self readAllAlbumsOnDevice];
    }

    else if (status == PHAuthorizationStatusDenied) {
         // Access has been denied.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Attention" message:@"Please give this app permission to access your photo library in your settings app!" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
        [alert show];
    }

    else if (status == PHAuthorizationStatusNotDetermined) {

         // Access has not been determined.
         [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {

             if (status == PHAuthorizationStatusAuthorized) {
                 // Access has been granted.
                 [self readAllAlbumsOnDevice];
             }

             else {
                 // Access has been denied.
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Attention" message:@"Please give this app permission to access your photo library in your settings app!" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
                 [alert show];
             }
         }];
    }

    else if (status == PHAuthorizationStatusRestricted) {
         // Restricted access - normally won't happen.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Attention" message:@"Please give this app permission to access your photo library in your settings app!" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
        [alert show];
    }
}

//get all the records from db
- (void) fetchLocationRecordsFromDatabase{
    [databaseRecords removeAllObjects];
    databaseRecords = [CoreDataUtils fetchLocationRecordsFromDatabase];
    
    if (!databaseRecords) {
        // Handle the error.
        // This is a serious error and should advise the user to restart the application
    }
    else {
        NSInteger count = 0;
        NSLog(@"LOADED %ld RECorDS FroM DB",databaseRecords.count);
        for(LocationDataModel *entity in databaseRecords) {
          //load the thumbnail or not? takes forever
          count++;
          [self loadAssetInfoFromDataModelIntoMap:entity];
        }
        NSLog(@"PROCESSED %ld", (long)count);
    }
    

   
}

#pragma asset stuff
-(void) loadAssetInfoFromDataModelIntoMap:(LocationDataModel*)model {
    //NSLog(@"Loading asset for model with assetURL %@: ",model.assetURL);
    
    NSString *assetURL = model.assetURL;
    //if it is an album found the match in the complete array, and get the list of photos
    NSMutableArray *photos = nil;
    if([model.type isEqualToString:TYPE_ALBUM]) {
        //if it is an album it will add the array of all the images on the album
        for(BHAlbum *album in self.albums) {
            if([album.assetURL isEqualToString:model.assetURL]) {
                photos = [[NSMutableArray alloc] initWithCapacity:album.photosCount];
                [photos addObjectsFromArray:album.photosURLs];
            }
        }
        
        if(photos == nil && model.assetURL==nil && model.thumbnailURL!=nil) {
            photos = [[NSMutableArray alloc] initWithObjects:model.thumbnailURL, nil];
            assetURL = model.thumbnailURL;
        }
        //single image
    } else if(assetURL!=nil) {
        photos = [[NSMutableArray alloc] initWithObjects:model.assetURL, nil];
    }
    
    //get the thumbnail
    if(assetURL!=nil) {
        
         
        PHFetchOptions *options = [PHFetchOptions new];
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
        
        PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsWithLocalIdentifiers:[[NSMutableArray alloc] initWithObjects: assetURL,nil] options:options];
        
        if(assets!=nil && assets.count > 0) {
            
            NSMutableArray *processed = [[NSMutableArray alloc] initWithCapacity:assets.count];

            PHAsset *asset = [assets firstObject];
            PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
            requestOptions.resizeMode   = PHImageRequestOptionsResizeModeExact;
            requestOptions.networkAccessAllowed = true;
            requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            requestOptions.synchronous = false;
              
            PHImageManager *imageManager = [PHImageManager defaultManager];
            
            [imageManager requestImageForAsset:asset
                                     targetSize:CGSizeMake(125.0f, 125.0f)
                                    contentMode:PHImageContentModeDefault
                                        options:requestOptions
                                  resultHandler:^void(UIImage *thumbnail, NSDictionary *info) {
                                      if(thumbnail!=nil && ![processed containsObject:asset.localIdentifier]) {
                                          
                                          //it can be called multiple times
                                          [processed addObject:asset.localIdentifier];
                                          
                                          //alwyas update the UI in the main thread
                                          dispatch_async(dispatch_get_main_queue(), ^{
                           
                                              //UIImage *imageFinal = imageFull;
                                              CLLocation *locationCL = [[CLLocation alloc] initWithLatitude:[model.latitude doubleValue]
                                                                                                  longitude:[model.longitude doubleValue]];
                                              //NSLog(@"Adding location to the map, read from database 1");
                                              //TODO add the full size here:
                                              NSString *desc = model.desc;
                                              if(desc == nil) {
                                                  desc = model.description;
                                              }
                                              [self.mapViewController addLocation:locationCL withImage:thumbnail andTitle:desc forModel:model containingURLS:photos];
                                              
                                          });
                                      }
                
            }];
        }
        
    }
    

}



/*
-(void) readNumberOfExistingAlbums{
    
    ALAssetsLibrary *assetsLib = [[ALAssetsLibrary alloc] init];
    numExistingAlbums =0;

    ////search all photo albums in the library
    [assetsLib enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if(group!=nil) {
            if([group valueForProperty:ALAssetsGroupPropertyName]!=nil) {
                numExistingAlbums = numExistingAlbums+1;
            }
        }
    
        NSLog(@"num existing albums %ld",numExistingAlbums);
     }
     
          failureBlock:^(NSError *error)  {
              NSLog(@"Error getting the albums");
           }
     
     ] ;
}*/

-(void) reloadAlbumsInfo {
    //[self readNumberOfExistingAlbums];
    [self.collectionView.collectionViewLayout invalidateLayout];
    [self.collectionView reloadData];
}

//creates a new Album if not exists
-(void) createNewAlbum: (NSString*) albumName completion:(void(^)(BOOL))callback {
    
    ALAssetsLibrary *assetsLib = [[ALAssetsLibrary alloc] init];
    
     __block BOOL albumExists = NO;
    
    ////search all photo albums in the library
    [assetsLib enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
        //compare the names of the albums
        if ([albumName compare: [group valueForProperty:ALAssetsGroupPropertyName]]==NSOrderedSame) {
            
            //target album is found
            albumExists = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSString *msg = [NSString stringWithFormat:@"Album %@ already exists!",albumName];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                message:msg
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            });
            if(callback!=nil) {
                callback(NO);
            }
            return;
        }
        
        if (group==nil && albumExists==NO) {
            //photo albums are over, target album does not exist, thus create it
            
            __weak ALAssetsLibrary* weakSelf = assetsLib;
            
            //create new assets album
            [weakSelf addAssetsGroupAlbumWithName:albumName
                                  resultBlock:^(ALAssetsGroup *group) {
                                      
                                      BHAlbum *album = [[BHAlbum alloc] init];
                                      album.photosURLs = [[NSMutableArray alloc] init];
                                      album.name = albumName;
                                      
                                      BHPhoto *photo = [BHPhoto photoWithImageData: [UIImage imageNamed:@"concrete"]];
                                      photo.imageURL = nil;
                                      [album addPhoto:photo];
                                      [self.albums addObject:album];
                                      
                                      
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          
                                          
                                          
                                          NSString *msg = [NSString stringWithFormat:@"Album %@ sucessfully added!",albumName];
                                          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                                          message:msg
                                                                                         delegate:nil
                                                                                cancelButtonTitle:@"OK"
                                                                                otherButtonTitles:nil];
                                          
                                          [alert show];
                                          
                                          
                                          [self.collectionView reloadData];
                                          
                                          if(callback!=nil) {
                                              callback(YES);
                                          }
                                          
                                      });
                                  }
             
                                  failureBlock:^(NSError *error)  {
                                     NSLog(@"Error Adding the album %@",albumName);
                                        if(callback!=nil) {
                                            callback(NO);
                                        }
                                  }
             ];
            //should be the last iteration anyway, but just in case
            return;
        }
        
        
    }
     
      failureBlock:^(NSError *error)  {
            NSLog(@"Error getting the albums");
       }
     
  ];//end albums enumeration
}

//----------------------------------------
/**
- (LocationDataModel *)reverseGeocode:(CLLocation *)location completion:(LocationDataModel *(^)(NSString *))callback  {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        NSLog(@"Finding address");
        if (error) {
            NSLog(@"Error %@", error.description);
            callback(@"NA");
        } else {
            CLPlacemark *placemark = [placemarks lastObject];
            //NSString *description = [NSString stringWithFormat:@"%d", ABCreateStringWithAddressDictionary(placemark.addressDictionary, NO)];
            NSLog(@"RESULT : %@", [placemark description]);
            callback([placemark description]);
        }
    }];
}*/
//---------------------------------

#pragma SAVE LOCATION RECORD

-(LocationDataModel *)saveLocationRecord:(NSString*)assetURL withDate:(NSDate*) date andLocation:(CLLocation*) imageLocation andAssetType: (NSString *) type andDescription: (NSString *) description {
    
    NSMutableArray *results = [CoreDataUtils fetchLocationRecordsFromDatabaseWithAssetURL:assetURL withManagedContext:self.managedObjectContext];
    //check if a record with this assetURL already exists on DB
    if(results==nil || results.count == 0) {
        //we only add the ones that do not exist
        //NSManagedObjectContext *managedObjectContext = [(PCAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        __block LocationDataModel *locationObject = (LocationDataModel *)[NSEntityDescription insertNewObjectForEntityForName:@"LocationDataModel" inManagedObjectContext:self.managedObjectContext];
        //current date
        if(date!=nil) {
            [locationObject setTimestamp: date];
        }
        else {
            [locationObject setTimestamp: [NSDate date]];
        }
        
        //TODO THE NAME SAME OF ASSET? WHY??? THERE IS A PROPER FIELD
        [locationObject setName: assetURL];
        [locationObject setDesc:description];//TODO pass this to the annotation title
        
        
        bool isAlbumType = false;
        
        if([type isEqualToString:TYPE_PHOTO])
        {
            //it is an image
            locationObject.type = TYPE_PHOTO;
            isAlbumType = false;
        }
        else {
            //TODO if it is an album, i need to show it on that location
            locationObject.type = TYPE_ALBUM;
            isAlbumType = true;
        }
        
        locationObject.assetURL = assetURL;
        locationObject.thumbnailURL = assetURL;//need to save it as a string
        
        BOOL __block OK = YES;
        NSError __block *error;
        
        
        if(imageLocation!=nil) {
            CLLocationCoordinate2D coordinate = imageLocation.coordinate;
            locationObject.latitude = [[NSString alloc] initWithFormat:@"%f", coordinate.latitude];
            locationObject.longitude= [[NSString alloc] initWithFormat:@"%f", coordinate.longitude];
        }
        else {
            locationObject.latitude = @"0000";
            locationObject.longitude= @"0000";
            
            
        }
        
        if(![managedObjectContext save:&error]){
            NSLog(@"Unable to save object error is: %@",error.description);
            OK= NO;
            //This is a serious error saying the record
            //could not be saved. Advise the user to
            //try again or restart the application.
        }
        
        if(OK==YES) {
        
            return locationObject;
        }
        
        
    }
    
    return nil;
    
    
}



-(void) readAllAlbumsOnDevice {
    
    //only images, not videos for now
    PHFetchOptions *options = [PHFetchOptions new];
    options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
    
    //smart albums
    PHFetchResult *smartAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
        for (PHAssetCollection *collection in smartAlbum){
            
            
            NSLog(@"ADDING Title for SMART Album= %@",collection.localizedTitle);
            [self.existingAlbumsNames addObject:collection.localizedTitle];
            BHAlbum *album = [[BHAlbum alloc] init];
            [album setName:collection.localizedTitle];
            [album setType:ALBUM_TYPE_SMART];
            [album setPhotosURLs: [[NSMutableArray alloc] init] ];
            [album setAssetURL:collection.localIdentifier];//the UUID
            [self.albums addObject:album];
            
            
            CLLocation *albumlocation = [collection approximateLocation];
            //NSLog(@"ADDING ALBUM NAME %@ for URL %@ LOCATION: %@", album.name, album.assetURL, albumlocation ? albumlocation.description : @"NOTHING");
            
            LocationDataModel *model;
            
            if(album.assetURL!=nil ) {
                NSMutableArray *locationModels = [CoreDataUtils fetchLocationRecordsFromDatabaseWithAssetURL: album.assetURL withManagedContext:self.managedObjectContext ];
                if(locationModels!= nil && locationModels.count > 0) {
                    model = [locationModels objectAtIndex:0];
                }
                //TODO need to see if there is already a location model for this asset before adding a new entry
            }
            else if(albumlocation!=nil) {
                model = [self saveLocationRecord:album.assetURL withDate:nil andLocation:albumlocation andAssetType:TYPE_ALBUM andDescription:album.name];
            }
            
            if(model!=nil && album.photos.count > 0) {
                BHPhoto *photo = [album.photos objectAtIndex:0];
                //GET THE album and
                [self.mapViewController addLocation:albumlocation withImage: photo.image  andTitle: model.desc forModel:model containingURLS:album.photosURLs];
            }
            
            //load all images in album
            [self parseImagesForAlbum:album fromCollection:collection withLocationDataModel:model];
            
        }

    //2. Get list of User created albums
    PHFetchResult *userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
        for (PHAssetCollection *collection in userAlbums){
            NSLog(@"ADDING Title for USER Album= %@",collection.localizedTitle);
            [self.existingAlbumsNames addObject:collection.localizedTitle];
            BHAlbum *album = [[BHAlbum alloc] init];
            [album setName:collection.localizedTitle];
            [album setType:ALBUM_TYPE_USER];
            [album setPhotosURLs: [[NSMutableArray alloc] init] ];
            [album setAssetURL:collection.localIdentifier];
            [self.albums addObject:album];
            
            
            CLLocation *albumlocation = [collection approximateLocation];
            //NSLog(@"ADDING ALBUM NAME %@ for URL %@ LOCATION: %@", album.name, album.assetURL, albumlocation ? albumlocation.description : @"NOTHING");
            
            LocationDataModel *model;
            if(album.assetURL!=nil ) {
                NSMutableArray *locationModels = [CoreDataUtils fetchLocationRecordsFromDatabaseWithAssetURL: album.assetURL withManagedContext:self.managedObjectContext];
                if(locationModels!= nil && locationModels.count > 0) {
                    model = [locationModels objectAtIndex:0];
                }
            }
            else if(albumlocation!=nil) {
                model = [self saveLocationRecord:album.assetURL withDate:nil andLocation:albumlocation andAssetType:TYPE_ALBUM andDescription:album.name];
            }
            
            if(model!=nil && album.photos.count > 0) {
                BHPhoto *photo = [album.photos objectAtIndex:0];
                //GET THE album and
                [self.mapViewController addLocation:albumlocation withImage: photo.image  andTitle: model.desc forModel:model containingURLS:album.photosURLs];
            }
            //load all images in album
            [self parseImagesForAlbum:album fromCollection:collection withLocationDataModel:model];
            
        }
}

/**
 Fetch all the images from the album
 */
-(void) parseImagesForAlbum: (BHAlbum *) album fromCollection:(PHAssetCollection *) collection withLocationDataModel: (LocationDataModel *) albumLocationModel {
 
    PHImageManager *imageManager = [PHImageManager defaultManager];
    
    PHFetchOptions *options = [PHFetchOptions new];
    options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
    
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:collection options:options];
    NSInteger numOfPicturesInAlbum = (assets == nil) ? 0 : assets.count;
    
    //grab the album location if any
    CLLocation *albumlocation = [collection approximateLocation];
    
    
    if(numOfPicturesInAlbum==0) {
        BHPhoto *photo = [BHPhoto photoWithImageData: [UIImage imageNamed:@"concrete"]];
        photo.imageURL = nil;
        [album addPhoto:photo];
    } else {
       
   
        //MAX_PHOTO_THUMBNAILS_PER_ALBUM is the max thumbnails i will read here, but i will grab all the thumbnails for the map
        //parse image
        NSUInteger *i = 0;
        //load the thumbnails for the first 3, and just add the url for the remaining
        
        NSMutableArray *processed = [[NSMutableArray alloc] initWithCapacity:assets.count];
        
        for(PHAsset *asset in assets) {
              if(asset!=nil) {
                  //grab the location if any
                  CLLocation *imageLocation = asset.location;
                  //save the URL of the asset Photo
                  NSString *assetPhotoURL = asset.localIdentifier;
                  //NSLog(@"asset photo url %@", asset.localIdentifier);
                  NSDate *theDate = asset.creationDate;
                  NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:theDate];
            
                  //check the year when the picture was taken
                  NSInteger year = components.year;
                  NSString *yearSTR = [NSString stringWithFormat:@"%ld",(long)year];
                  
                  //check if the existing list of albums contains the year of this photo?
                  BHAlbum *auxiliar = [self albumsContainsName:yearSTR];
                  
                  
                  //check if we have an album on our collection with the same title (year)
                  //if not we add this fake album now
                  BOOL existsNativeAlbumWithSameName = [self.existingAlbumsNames containsObject:yearSTR];
                  
                  //these are FAKE yearly albums, not on the device itself
                  if(!existsNativeAlbumWithSameName && ![self.albumsYears containsObject:yearSTR] && auxiliar==nil) {
                      NSLog(@"ADDING FAKE ALBUM FOR YEAR %@", yearSTR);
                      [self.albumsYears addObject: yearSTR];
                      
                      BHAlbum *albumForYear = [[BHAlbum alloc] init];
                      albumForYear.photosURLs = [[NSMutableArray alloc] init];
                      albumForYear.assetURL = nil;
                      albumForYear.name = yearSTR;
                      [albumForYear setType:ALBUM_TYPE_FAKE];
            
                      [self.albums addObject:albumForYear]; //was album
                      
                      //save the reference to it
                      auxiliar = albumForYear;
                  
                      
                  }
                  
                  //------------------------------ TODO check repetitive code -----------------------------------------------
                   //check if this asset/image was already added to the current album (NOTE: this is not not counting the yearly album here)
                   
                   //INSERT THE PICTURE INTO THE NORMAL ALBUM
                   
                   //----------------------------------------------------------------------------------
                   [album.photosURLs addObject: assetPhotoURL];
                  
                  //NSLog(@"2 - NUMBER OF PHOTOS FOR ALBUM %@ %lu", album.name, (unsigned long)album.photosURLs.count);
                  
                   //INSERT THE PICTURE INTO THE AUXILIAR/YEARLY ALBUM;
                   
                   //----------------------------------------------------------------------------------
                   if( auxiliar!=nil && [self albumContainsAssetURL:auxiliar assetURL:assetPhotoURL] == NO) {
                       [auxiliar.photosURLs addObject: assetPhotoURL];
                   }
                   //------------------------------------------------------------------------------------
                       
                  __block UIImage *thumbnailImage = nil;
                  
                    if( (album.photos.count < MAX_PHOTO_THUMBNAILS_PER_ALBUM) || (auxiliar!=nil && auxiliar.photos.count < MAX_PHOTO_THUMBNAILS_PER_ALBUM)  ) {
                        
                        PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
                        requestOptions.resizeMode   = PHImageRequestOptionsResizeModeExact;
                        requestOptions.networkAccessAllowed = true;
                        requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
                        requestOptions.synchronous = true;
                          
                        //---------------- PARSE THUMBNAIL
                        [imageManager requestImageForAsset:asset
                                                 targetSize:CGSizeMake(125.0f, 125.0f)
                                                contentMode:PHImageContentModeDefault
                                                    options:requestOptions
                                              resultHandler:^void(UIImage *thumbnail, NSDictionary *info) {
                                                  if(thumbnail!=nil && ![processed containsObject:assetPhotoURL]) {
                                                      
                                                      [processed addObject:assetPhotoURL];
                                                      
                                                      thumbnailImage = thumbnail;
                                                      
                                                     //add the photo and reload the collection view
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          
                                                          if(album.photos.count < MAX_PHOTO_THUMBNAILS_PER_ALBUM) {
                                                              BHPhoto *photo = [BHPhoto photoWithImageData: thumbnail];
                                                              photo.imageURL = assetPhotoURL;
                                                              [album addPhoto:photo];
                                                          }
                                                          
                                                          //also add to the auxiliar album
                                                          if(auxiliar!=nil && auxiliar.photos.count < MAX_PHOTO_THUMBNAILS_PER_ALBUM) {
                                                              
                                                              BHPhoto *photo = [BHPhoto photoWithImageData: thumbnail];
                                                              photo.imageURL = assetPhotoURL;
                                                              [auxiliar addPhoto:photo];
                                                          }
                                                          
                                                          //reload collectiuon view
                                                          [self.collectionView reloadData];
                                                          
                                                          
                                                      });
                                                  }
                                                  
                        }];
                        //-------------------- PARSE LOCATION
                        
                            
                        //---------------------------
                    }
                  
                  
                  
                  
                  
                   //--------------------------------------------------------------------------------------
                  
                    //TODO for each album i only need 3 thumbnails, so i do not need this loop
                  
                    /*PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
                    requestOptions.resizeMode   = PHImageRequestOptionsResizeModeExact;
                    requestOptions.networkAccessAllowed = true;
                    requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
                    requestOptions.synchronous = true;
                      
                    [imageManager requestImageForAsset:asset
                                             targetSize:CGSizeMake(125.0f, 125.0f)
                                            contentMode:PHImageContentModeDefault
                                                options:requestOptions
                                          resultHandler:^void(UIImage *thumbnail, NSDictionary *info) {
                                              if(thumbnail!=nil) {*/
                                                  
                                                  //ONLY process maximum of 3 images per album
                                                  //the rest only need to be processed when we present the album details
                                                  /*if(album.photos.count < MAX_PHOTO_THUMBNAILS_PER_ALBUM) {
                                     
                                                      
                                                      //add the photo and reload the collection view
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          
                                                          BHPhoto *photo = [BHPhoto photoWithImageData: thumbnail];
                                                          photo.imageURL = assetPhotoURL;
                                                          [album addPhoto:photo];
                                                          
                                                          //also add to the auxiliar album
                                                          if(auxiliar!=nil && auxiliar.photos.count < MAX_PHOTO_THUMBNAILS_PER_ALBUM) {
                                                              
                                                              BHPhoto *photo = [BHPhoto photoWithImageData: thumbnail];
                                                              photo.imageURL = assetPhotoURL;
                                                              [auxiliar addPhoto:photo];
                                                          }
                                                          
                                                          //reload collectiuon view
                                                          [self.collectionView reloadData];
                                                          
                                                          
                                                      });
                                                      
                                                  }
                                                  
                                                  
                                                  //insert max 3 thumbnails on the yearly album as well
                                                  //ONLY process maximum of 3 images per album
                                                  if( auxiliar!=nil && (auxiliar.photos.count <  MAX_PHOTO_THUMBNAILS_PER_ALBUM ) ) {
                                               
                                                      
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          
                                                          BHPhoto *photo = [BHPhoto photoWithImageData: thumbnail];
                                                          photo.imageURL = assetPhotoURL;
                                                          [auxiliar addPhoto:photo];
                                                          [self.collectionView reloadData];
                                                          
                                                          
                                                      });
                                                      
                                                      //NSLog(@"PROCESSED YEAR ALBUM %@ IMAGES %ld", auxiliar.name, (long) processedImagesInYearlyAlbum);
                                                  }*/
                                                  
                                                  
                                                  //SEE IF WE ALREADY HAVE A CUSTOME RECORD FOR THIS (TAKES PRECEDENCE)
                                                  NSMutableArray *photoModels = [CoreDataUtils fetchLocationRecordsFromDatabaseWithAssetURL: assetPhotoURL withManagedContext:self.managedObjectContext ];
                                                  
                                                  //NO location info for this photo url is known yet
                                                  if(photoModels == nil || photoModels.count == 0) {
                                                      
                                                      //save the location of the record on the location model
                                                      NSString *desc = nil;
                                                      if(imageLocation==nil) {
                                                          //no saved location for this photo, check if we have something for the album first
                                                
                                                          desc = [NSString stringWithFormat:@"%lu",(long)i];
                                                          
                                                          if(albumLocationModel!=nil) {//ok, we have album location data model
                                                              
                                                              //NSLog(@"Adding image location to the map from pre-existing album location");
                                                              NSMutableArray *urls = [[NSMutableArray alloc] initWithObjects:assetPhotoURL, nil];
                                                             [self.mapViewController addLocation:albumlocation withImage: thumbnailImage  andTitle: albumLocationModel.desc forModel:albumLocationModel containingURLS:urls];
                                                              
                                                          } else if(albumlocation!=nil) { //no data modelk but coordinates exist
                                                              
                                                              //SAVE THE RECORD WITH THE ALBUM LOCATION
                                                              //TODO pass description of image
                                                              LocationDataModel *model = [self saveLocationRecord: assetPhotoURL withDate:theDate andLocation:albumlocation andAssetType:TYPE_PHOTO andDescription:desc];
                                                              
                                                              if(model!=nil) {
                                                                  //NSLog(@"Adding image location to the map from album location");
                                                                  NSMutableArray *urls = [[NSMutableArray alloc] initWithObjects:assetPhotoURL, nil];
                                                              [self.mapViewController addLocation:albumlocation withImage: thumbnailImage  andTitle: model.desc forModel:model containingURLS:urls];
                                                              }
                                                          }//else do  nothing, no location is known, neither for the photo or the album
                                                          
                                                          
                                                      }
                                                      else  {// imageLocation!=nil
                                                          
                                                          //SAVE THE RECORD (not saving any images or pics) WITH THE PHOTO LOCATION
                                                          //There is an exif cordinate???
                                                          //if we have location data, add the annotation to the map
                                                          desc = [NSString stringWithFormat:@"IMG-%lu",(long)i];
                                                          //IF the record already exists keep the previous title/description on the model, not this new one
                                                          
                                                          //NSLog(@"SAVING %@ with photo own location %@",assetPhotoURL,imageLocation.description);
                                                          LocationDataModel *model = [self saveLocationRecord:assetPhotoURL withDate:theDate andLocation:imageLocation andAssetType:TYPE_PHOTO andDescription:desc];
                                                        
                                                          if(model!=nil && model.latitude!=nil && model.longitude!=nil) {
                                                              //NSLog(@"Adding image location to the map from image exif data");
                                                              NSMutableArray *urls = [[NSMutableArray alloc] initWithObjects:assetPhotoURL, nil];
                                                            [self.mapViewController addLocation:imageLocation withImage: thumbnailImage  andTitle: model.desc forModel:model containingURLS:urls];
                                                          }
                                                          
                                                      }
                                                  } else {
                                                      
                                                     //we already have location data model
                                                     LocationDataModel *model = [photoModels objectAtIndex:0];
                                                      
                                                      if(model!=nil && model.latitude!=nil && model.longitude!=nil) {
                                                          //TODO I ALREADY HAVE THIS INFO, JUST UPDATE THE MAP VIEW
                                                          // NSLog(@"Adding image location to the map from image already existing location data");
                                                        NSMutableArray *urls = [[NSMutableArray alloc] initWithObjects:assetPhotoURL, nil];
                                                            
                                                        CLLocation *location = [[CLLocation alloc] initWithLatitude:[model.latitude doubleValue] longitude:[model.longitude doubleValue]];
                                                       [self.mapViewController addLocation:location withImage: thumbnailImage  andTitle: model.desc forModel:model containingURLS:urls];
                                                      }
                             
                                                  }//end else, location already previously saved
                                                 
                          // end resultHandler }
                                              
                       // }];
                  //---------------------------------------------------------

                    
              }
              i++;
          }
            
    
    }
    

 
}



//fetch the given album by the name and his type
-(BHAlbum *) fetchAlbumByName: (NSString *) name andType:(NSString *) type {
    for (BHAlbum *album in self.albums){
        if([album.name isEqualToString:name] && [album.type isEqualToString:type]) {
            return album;
        }
    }
    return nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//check if album already exists
- (BHAlbum *) albumsContainsName: (NSString *) name {
    for(BHAlbum *album in albums) {
        if([album.name isEqualToString:name]) {
            return album;
        }
    }
    return nil;
}
//check if the asset url is already there
-(BOOL) albumContainsAssetURL: (BHAlbum *)album assetURL: (NSString*) urlToString {
    for(NSString * theURL in album.photosURLs) {
        if([urlToString isEqualToString:theURL]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - View Rotation

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        self.photoAlbumLayout.numberOfColumns = 3;
        
        // handle insets for iPhone 4 or 5
        CGFloat sideInset = [UIScreen mainScreen].preferredMode.size.width == 1136.0f ?
                            45.0f : 25.0f;
        
        self.photoAlbumLayout.itemInsets = UIEdgeInsetsMake(22.0f, sideInset, 13.0f, sideInset);
        
    } else {
        self.photoAlbumLayout.numberOfColumns = 2;
        self.photoAlbumLayout.itemInsets = UIEdgeInsetsMake(22.0f, 22.0f, 13.0f, 22.0f);
    }
}

#pragma mark - UICollectionViewDataSource

//is the number of albums
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    //NSLog(@"NUM sections %lu",(unsigned long)self.albums.count);
    return self.albums.count > 0 ? self.albums.count : 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if(self.albums.count >0) {
        BHAlbum *album = self.albums[section];
        //NSLog(@"number of items for album %@ is  %ld",album.name, (unsigned long)album.photos.count);
        //NOTE empty albums will always contain the default cover photo (concrete)
        return album.photos.count;
    }
    return 0;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
   
    BHAlbumPhotoCell *photoCell =
        [collectionView dequeueReusableCellWithReuseIdentifier:PhotoCellIdentifier
                                                  forIndexPath:indexPath];
    
    NSInteger row = indexPath.section;
    NSInteger photoIndex = indexPath.item;
    
    if(row < self.albums.count ) {
   
        BHAlbum *album = self.albums[row];
        NSInteger tag = row;
        
        if(photoIndex < album.photos.count && photoIndex < MAX_PHOTO_THUMBNAILS_PER_ALBUM) {
            //NSLog(@"PHOTO INDEX %ld", photoIndex);
            //photoIndex gives me the album
            BHPhoto *photo = album.photos[photoIndex];
            
      
                //UIImage *image = [UIImage imageWithCGImage:[photo.rawImage fullScreenImage]];
                UIImage *image = [photo image];
           
               
                dispatch_async(dispatch_get_main_queue(), ^{
                    photoCell.imageView.image = image;
                            
                });
            
                photoCell.imageView.userInteractionEnabled = YES;
                photoCell.imageView.tag = tag;
                UITapGestureRecognizer *tapGesture =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapAlbumWithGesture:)];
                        [photoCell.imageView addGestureRecognizer:tapGesture];
  
        }
        
    }
    
    
    
    

    return photoCell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath;
{
    BHAlbumTitleReusableView *titleView =
        [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                           withReuseIdentifier:AlbumTitleIdentifier
                                                  forIndexPath:indexPath];
    NSInteger row = indexPath.section;
    if(row < self.albums.count) {
        BHAlbum *album = self.albums[indexPath.section];
        titleView.titleLabel.text = album.name;
    }
    else {
        titleView.titleLabel.text = [NSString stringWithFormat:@"%d",row ];
    }
    

    return titleView;
}

//show the input new album dialog
- (IBAction)addAlbumClicked:(id)sender{
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"New album..." message:@"Enter the album name" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save",nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

- (IBAction)settingsClicked:(id)sender{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:@"Will show a listview here"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];

}

//the delegate for the new Album
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(buttonIndex==1) { //0 - cancel, 1 - save
        NSString *albumName = [alertView textFieldAtIndex:0].text;
        [self createNewAlbum:albumName completion:nil];
    }
    
}


//clicked on a empty album and show all the pics inside (if any)
- (void)didTapAlbumWithGesture:(UITapGestureRecognizer *)tapGesture{
   
    UIImageView *imageView = (UIImageView*)tapGesture.view;
    NSInteger tag = imageView.tag;
    
    BOOL isSameAlbumAsBefore = false;
    if(tag<albums.count) {
        //valid index
        BHAlbum *selectedOne = [albums objectAtIndex:tag];
        NSLog(@"selected one : %@", selectedOne.name);
        
        //TODO IT IS HERE (i am not copying everything??)
        albumViewController.title = selectedOne.name;
        
        isSameAlbumAsBefore = (albumViewController.selectedAlbum!=nil && [albumViewController.selectedAlbum.name isEqualToString:selectedOne.name]);
        
        albumViewController.selectedAlbum = selectedOne;
        albumViewController.selectedAlbumIndex = tag;
        
        if(!isSameAlbumAsBefore) {
               
               NSMutableArray *arrayOfNames = [[NSMutableArray alloc] init];
               //not the fake ones
               NSMutableArray *albumsWhereWeCanAddPhotos = [[NSMutableArray alloc] init];
               
               for(BHAlbum *album in albums) {
                   NSLog(@"adding ALBUM %@",album);
                   [arrayOfNames addObject:album.name];
                   if(![album isFakeAlbum]) {
                       [albumsWhereWeCanAddPhotos addObject:album.name];
                   }
               }
               //TODO NEXT do not add fake ones as we cannot save photo to those (they show on the list of options)
               [albumViewController addAlbumsNamesFromArray:albumsWhereWeCanAddPhotos];
           }
        
           
           
           
           //remove the one on the left , leaving only the back button
           albumViewController.navigationItem.leftBarButtonItem=nil;
           //pass this one so i can call some things back, like deleteAlbum
           albumViewController.rootViewController = self;
           [self.navigationController pushViewController: albumViewController animated:NO];
        
    }
    
    
  
    
    
}

//create an album {

/*
ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
[library addAssetsGroupAlbumWithName:@"MY APP NAME" resultBlock:^(ALAssetsGroup *group) {
    //How to get the album URL?
} failureBlock:^(NSError *error) {
    //Handle the error
}];
*/
//call share kit
- (void)myButtonHandlerAction
{
	// Create the item to share (in this example, a url)
	NSURL *url = [NSURL URLWithString:@"http://getsharekit.com"];
	SHKItem *item = [SHKItem URL:url title:@"ShareKit is Awesome!"];
    
	// Get the ShareKit action sheet
	SHKActionSheet *actionSheet = [SHKActionSheet actionSheetForItem:item];
    
	// Display the action sheet
	[actionSheet showFromToolbar:self.navigationController.toolbar];
}

-(void) deleteAlbum: (BHAlbum *) album completion:(void(^)(BOOL))callback {
    
    NSUInteger count = self.albums.count;
    [self.albums removeObject:album];
    if(self.albums.count < count) {
        callback(true);
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.collectionView reloadData];
            
        });
    }else {
        callback(false);
    }
    
}


@end
