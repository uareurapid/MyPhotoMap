//
//  BHCollectionViewController.m
//  CollectionViewTutorial
//
//  Created by Bryan Hansen on 11/3/12.
//  Copyright (c) 2012 Bryan Hansen. All rights reserved.
//

#import "BHCollectionViewController.h"

#import "BHAlbumPhotoCell.h"
#import "BHAlbum.h"
#import "BHPhoto.h"
#import "BHAlbumTitleReusableView.h"
#import "MYAlbumViewController.h"
#import "SearchLocationViewController.h"
#import "PhotosMapViewController.h"


@interface BHCollectionViewController ()



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

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle {
    self = [super initWithNibName:nibName bundle:nibBundle];
    if(self) {
        albums = [NSMutableArray array];
        assetsURLs = [[NSMutableArray alloc] init];
        albumsYears = [[NSMutableArray alloc] init];
        
        self.title = @"Your Albums";
        
        addAlbumButton = [[UIBarButtonItem alloc] initWithTitle:@"Settings"
                          style:UIBarButtonItemStyleDone target:self action:@selector(settingsClicked:)];
        
        self.navigationItem.rightBarButtonItem = addAlbumButton;
        
        
        
        UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithTitle:@"Add"
                                                          style:UIBarButtonItemStyleDone target:self action:@selector(addAlbumClicked:)];
        
 
       
        self.navigationItem.leftBarButtonItem = left;
        
        
        
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
    
    [self.collectionView registerClass:[BHAlbumPhotoCell class]
            forCellWithReuseIdentifier:PhotoCellIdentifier];
    [self.collectionView registerClass:[BHAlbumTitleReusableView class]
            forSupplementaryViewOfKind:BHPhotoAlbumLayoutAlbumTitleKind
                   withReuseIdentifier:AlbumTitleIdentifier];
    
    self.thumbnailQueue = [[NSOperationQueue alloc] init];
    self.thumbnailQueue.maxConcurrentOperationCount = 3;
    
    //The following code for example does nothing more than get the number of photos in the camera roll, but will be enough to trigger the permission prompt.
    ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
    [lib enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        NSLog(@"%zd", [group numberOfAssets]);
    } failureBlock:^(NSError *error) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Attention" message:@"Please give this app permission to access your photo library in your settings app!" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
        [alert show];
        
        if (error.code == ALAssetsLibraryAccessUserDeniedError) {
            NSLog(@"user denied access, code: %zd", error.code);
        } else {
            NSLog(@"Other error code: %zd", error.code);
        }
    }];
    
    //TODO check if appearing twice
    //check permissions
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    if (status != ALAuthorizationStatusAuthorized) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Attention" message:@"Please give this app permission to access your photo library in your settings app!" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    self.existingAlbumsNames = [[NSMutableArray alloc] init];
    
    //clear annotations
    [mapViewController removeAnnotations];
    
    [self readAllAlbumsOnDevice];

    //first get all the stuff on the device
    //[self readCameraRoll];
    
    //and now load all existing data from database
    [self fetchLocationRecordsFromDatabase];
    
    
    
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
            //load the thumbnail
            //if(entity.assetURL!=nil) {
                count++;
                [self loadAssetInfoFromDataModelIntoMap:entity];
            //} else if {
            //    NSLog(@"TODFOSSOSOOSOSOSOSOSOSOOSOO FAKE ALBUM STUPID!!1 %@ %@", entity.thumbnailURL, entity.type);
            //}
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
    
    
    
    //do the assets enumeration
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *asset){
        
        CGImageRef thumb = [asset thumbnail];
        
     
        if(thumb!=nil /*&& imageFull!=nil*/) {
            
            __block UIImage *imageThumb = [UIImage imageWithCGImage:thumb];
            
            //alwyas update the UI in the main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                
                UIImage *image = imageThumb;
                //UIImage *imageFinal = imageFull;
                CLLocation *locationCL = [[CLLocation alloc] initWithLatitude:[model.latitude doubleValue]
                                                                    longitude:[model.longitude doubleValue]];
                NSLog(@"Adding location to the map, read from database 1");
                //TODO add the full size here:
                [self.mapViewController addLocation:locationCL withImage:image andTitle:model.description forModel:model containingURLS:photos];                
                
            });
        }
        
        
    };
    
    ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror){
        NSLog(@"Failed to get image for assetURL %@: ",model.assetURL);
        //failed to get image.
    };
    
    ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
    [assetslibrary assetForURL: [NSURL URLWithString: assetURL ] resultBlock:resultblock failureBlock:failureblock];
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

#pragma SAVE RECORD

-(LocationDataModel *)saveLocationRecord:(NSString*)assetURL withDate:(NSDate*) date andLocation:(CLLocation*) imageLocation andAssetType: (NSString *) type {
    
    NSMutableArray *results = [CoreDataUtils fetchLocationRecordsFromDatabaseWithAssetURL:assetURL];
    //check if a record with this assetURL already exists on DB
    if(results==nil || results.count == 0) {
        //we only add the ones that do not exist
        NSManagedObjectContext *managedObjectContext = [(PCAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        LocationDataModel *locationObject = (LocationDataModel *)[NSEntityDescription insertNewObjectForEntityForName:@"LocationDataModel" inManagedObjectContext:managedObjectContext];
        //current date
        if(date!=nil) {
            [locationObject setTimestamp: date];
        }
        else {
            [locationObject setTimestamp: [NSDate date]];
        }
        
        [locationObject setName: assetURL];
        [locationObject setDesc:@"NA"];
        
        if(imageLocation!=nil) {
            CLLocationCoordinate2D coordinate = imageLocation.coordinate;
            locationObject.latitude = [[NSString alloc] initWithFormat:@"%f", coordinate.latitude];
            locationObject.longitude= [[NSString alloc] initWithFormat:@"%f", coordinate.longitude];
        }
        else {
            locationObject.latitude = @"0000";
            locationObject.longitude= @"0000";
        }
        
        
        
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
        
        
        BOOL OK = YES;
        NSError *error;
        if(![managedObjectContext save:&error]){
            NSLog(@"Unable to save object error is: %@",error.description);
            OK= NO;
            //This is a serious error saying the record
            //could not be saved. Advise the user to
            //try again or restart the application.
        }
        
        //[locationEntitiesArray insertObject:locationObject atIndex:0];
        
        
        if(OK==YES) {
        
            return locationObject;
       }
    }
    
    return nil;
    
    
}

//----------------------------------------

/*
- (void) readCameraRollV2 {
    
    for(BHAlbum *album in self.albums) {
      
        NSString *name = album.name;
        NSString *type = album.type;
        
        
    }
}*/

//will read all the albums on th card and their contents
/**
- (void) readCameraRoll {
    
    
    //UIImage* __block image = [[UIImage alloc] init];
    ALAssetsLibrary *assetsLib = [[ALAssetsLibrary alloc] init];

    
    //this is the max thumbnails i will read here, but i will grab all the thumbnails
    NSInteger maxNumPhotosPerAlbum = 3;
    __block NSInteger processedImages = 0;
    __block NSInteger processedImagesInYearlyAlbum = 0;
    
    [assetsLib enumerateGroupsWithTypes:ALAssetsGroupAll
     
                      usingBlock:^(ALAssetsGroup *group, BOOL *stop)
     {
        
         NSString *name = [group valueForProperty:ALAssetsGroupPropertyName];
         
         //name of the group/album
         if(name!=nil) {
             
             
             __block NSInteger albumProcessedImages = 0;
 
             BOOL existsAlbum = [self albumsContainsName:name];// [self.existingAlbumsNames containsObject:name];
             BHAlbum *album = nil;
             
             CLLocation *albumlocation;
             //get the number of pictures inside each album
             NSInteger numOfPicturesInAlbum = [group numberOfAssets];
             
             //ALBUM WITH THIS NAME DOES NOT EXIST YET!!
             /*if( !existsAlbum) {
                 
                 album = [[BHAlbum alloc] init];
                 album.photosURLs = [[NSMutableArray alloc] init];
                 album.assetURL = [group valueForProperty:ALAssetsGroupPropertyURL];
                 album.name = name;
                 
                 [self.albums addObject:album];
                 
                 //get only the first 3 images thumbnails to display
                 
                 
                 album.photosCount = numOfPicturesInAlbum;
                 
                 //album doesn´t have any photo, add a default empty one
                 if(numOfPicturesInAlbum==0) {
                     BHPhoto *photo = [BHPhoto photoWithImageData: [UIImage imageNamed:@"concrete"]];
                     photo.imageURL = nil;
                     [album addPhoto:photo];
                 }
                 
                 //SAVE THE LOCATION MODEL FOR THE ALBUM
                 //could be nil or null?
                 albumlocation = [group valueForProperty:ALAssetPropertyLocation];
                 
                 NSLog(@"ADDING ALBUM NAME %@ for URL %@ LOCATION: %@", album.name, album.assetURL, albumlocation ? albumlocation.description : @"NOTHING");
                 
                 
             
             }*/
      
      
             //à segunda
             /*
             for(int i = 0; i < numOfPicturesInAlbum; i++) {//just grab the first image
                 
                 
                     //start sorting the image assets inside the album
                     [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:i] options:0 usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop)
                      {
                          if (result != nil) {
                              
                              BHAlbum *auxiliar;
                              
                              
                              NSString *type = [result valueForProperty:ALAssetPropertyType];//only images for now
                              CLLocation *imageLocation = [result valueForProperty:ALAssetPropertyLocation];
                              
                              //it is a photo (we are only interested in photos, not other objects)
                              if([type isEqualToString:ALAssetTypePhoto]) {
                                  
                                  //save the URL of the asset Photo
                                  NSURL *assetPhotoURL = [result valueForProperty:ALAssetPropertyAssetURL];
                                  NSDate *theDate = [result valueForProperty:ALAssetPropertyDate];
                                  NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:theDate];
                                  
                                  
                                  //get the thumbnail
                                  __block UIImage *thumbnail = [UIImage imageWithCGImage:[result thumbnail]];
                                  
                                  
                                  //assets-library://asset/asset.JPG?id=BA92E651-26A9-476B-ADB3-CFF192F0F948&ext=JPG
                                  if(imageLocation==nil && albumlocation!=nil) {
                                      //SAVE THE RECORD WITH THE ALBUM LOCATION
                                      NSLog(@"SAVING %@ with album location %@", assetPhotoURL.absoluteString, albumlocation.description);
                                      LocationDataModel *model = [self saveLocationRecord:assetPhotoURL withDate:theDate andLocation:albumlocation];
                                      
                                      if(model!=nil) {
                                          NSLog(@"Adding image location to the map from album location");
                                          NSMutableArray *urls = [[NSMutableArray alloc] initWithObjects:assetPhotoURL.absoluteString, nil];
                                          [self.mapViewController addLocation:albumlocation withImage: thumbnail  andTitle: [NSString stringWithFormat:@"%d",i] forModel:model containingURLS:urls];
                                      }
                                      
                                  }
                                  else if(imageLocation!=nil) {
                                      //SAVE THE RECORD (not saving any images or pics) WITH THE PHOTO LOCATION
                                      //There is an exif cordinate???
                                      //if we have location data, add the annotation to the map
                                      
                                      NSLog(@"SAVING %@ with photo own location %@",assetPhotoURL.absoluteString,imageLocation.description);
                                      LocationDataModel *model = [self saveLocationRecord:assetPhotoURL withDate:theDate andLocation:imageLocation];
                                    
                                      if(model!=nil) {
                                          NSLog(@"Adding image location to the map from exif 1");
                                          NSMutableArray *urls = [[NSMutableArray alloc] initWithObjects:assetPhotoURL.absoluteString, nil];
                                          [self.mapViewController addLocation:imageLocation withImage: thumbnail  andTitle: [NSString stringWithFormat:@"IMG-%d",i] forModel:model containingURLS:urls];
                                      }
                                      
                                  }
                                  //TODOFIXME
                                  /**
                                   2019-10-24 16:06:58.879541+0100 MyPhotoMap[1286:70481] This app has attempted to access privacy-sensitive data without a usage description. The app's Info.plist must contain both “NSLocationAlwaysAndWhenInUseUsageDescription” and “NSLocationWhenInUseUsageDescription” keys with string values explaining to the user how the app uses this data
                                   *
                                  //check the year when the picture was taken
                                  NSInteger year = components.year;
                                  NSString *yearSTR = [NSString stringWithFormat:@"%ld",(long)year];
                                  
                                  //check if the existing list of albums contains the year of this photo?
                                  auxiliar = [self albumsContainsName:yearSTR];
                                  
                                  //check if we have an album on our collection with the same title (year)
                                  //if not we add this fake album now
                                                                       
                                  BOOL existsNativeAlbumWithSameName = [self.existingAlbumsNames containsObject:yearSTR];
                                  
                                  //these are FAKE yearly albums, not on the device itself
                                  if(!existsNativeAlbumWithSameName && ![self.albumsYears containsObject:yearSTR] && auxiliar==nil) {
                                      
                                      NSLog(@"ADDING CUSTOM/FAKE ALBUM FOR YEAR %@",yearSTR);
                                      [self.albumsYears addObject: yearSTR];
                                      
                                      BHAlbum *albumForYear = [[BHAlbum alloc] init];
                                      albumForYear.photosURLs = [[NSMutableArray alloc] init];
                                      albumForYear.assetURL = nil;
                                      albumForYear.name = yearSTR;
                                      
                                      
                                     
                                      [self.albums addObject:albumForYear]; //was album
                                      
                                      //save the reference to it
                                      auxiliar = albumForYear;
                                  
                                      
                                  }
                                  
                               
                                  //------------------------------ TODO check repetitive code -----------------------------------------------
                                  //check if this asset/image was already added to the current album (NOTE: this is not not counting the yearly album here)
                                  
                                  //INSERT THE PICTURE INTO THE NORMAL ALBUM
                                  
                                  //----------------------------------------------------------------------------------
                                  if( [self albumContainsAssetURL:album assetURL:assetPhotoURL] == NO) {
                                 
                                      [album.photosURLs addObject: assetPhotoURL];
                                      
                                      
                                      //ONLY process maximum of 3 images per album
                                      if(albumProcessedImages < maxNumPhotosPerAlbum) {
                                          albumProcessedImages = albumProcessedImages +1;
                                          //NSLog(@"Processed image %ld for album name: %@", albumProcessedImages, name);
                                          
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              
                                              BHPhoto *photo = [BHPhoto photoWithImageData: thumbnail];
                                              photo.imageURL = assetPhotoURL;
                                              [album addPhoto:photo];
                                              [self.collectionView reloadData];
                                              
                                              
                                          });
                                      }
                                      
                                  }
                                  //----------------------------------------------------------------------------------
                                 
                                  //INSERT THE PICTURE INTO THE AUXILIAR/YEARLY ALBUM;
                                  
                                  //----------------------------------------------------------------------------------
                                  if( auxiliar!=nil && [self albumContainsAssetURL:auxiliar assetURL:assetPhotoURL] == NO) {
                                      
                                      [auxiliar.photosURLs addObject: assetPhotoURL];
                                      //get the thumbnail
                                      __block UIImage *thumbnail = [UIImage imageWithCGImage:[result thumbnail]];
                                      
                                      //ONLY process maximum of 3 images per album
                                      if(processedImagesInYearlyAlbum <  (maxNumPhotosPerAlbum * self.albums.count) ) {
                                          processedImagesInYearlyAlbum = processedImagesInYearlyAlbum +1;
                                          
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              
                                              BHPhoto *photo = [BHPhoto photoWithImageData: thumbnail];
                                              photo.imageURL = assetPhotoURL;
                                              [auxiliar addPhoto:photo];
                                              [self.collectionView reloadData];
                                              
                                              
                                          });
                                      }
                                    
                                  }
                                  //------------------------------------------------------------------------------------
                                  
                              }
                              
                              
                          }
                      
                      
                      }];//end enumerateAssetsAtIndexes
                 
             } //end for LOOP
             
             /*
             if(albumlocation!=nil) {
                 LocationDataModel *model = [self saveLocationRecord:album.assetURL withDate:nil andLocation:albumlocation];
                 if(model!=nil && album.photos.count > 0) {
                     BHPhoto *photo = [album.photos objectAtIndex:0];
                     //GET THE album and
                     [self.mapViewController addLocation:albumlocation withImage: photo.image  andTitle: name forModel:model containingURLS:album.photosURLs];
                 }
                 
             }
                
             
         }//end if name !=nil
         
         
     }
     
            failureBlock:^(NSError *error)  {
                NSLog(@"Error reading phone images");
                // User did not allow access to library
                // .. handle error
            }
     
     ] ;

    
}*/


-(void) readAllAlbumsOnDevice {
    
    //only images, not videos for now
    PHFetchOptions *options = [PHFetchOptions new];
    options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
    
    //smart albums
    PHFetchResult *smartAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
        for (PHAssetCollection *collection in smartAlbum){
            
            
            /*BOOL existsAlbum = [self.existingAlbumsNames containsObject:collection.localizedTitle];
            BHAlbum *album = nil;

            
            //ALBUM WITH THIS NAME DOES NOT EXIST YET!!
            if( !existsAlbum) {
                
                album = [[BHAlbum alloc] init];
                album.photosURLs = [[NSMutableArray alloc] init];
                album.assetURL = collection.localizedTitle;
                album.name = collection.localizedTitle;
            }*/
            
            
            NSLog(@"ADDING Title for SMART Album= %@",collection.localizedTitle);
            [self.existingAlbumsNames addObject:collection.localizedTitle];
            BHAlbum *album = [[BHAlbum alloc] init];
            [album setName:collection.localizedTitle];
            [album setType:ALBUM_TYPE_SMART];
            [album setPhotosURLs: [[NSMutableArray alloc] init] ];
            [album setAssetURL:collection.localIdentifier];//the UUID
            [self.albums addObject:album];
            
            //load all images in album
            [self parseImagesForAlbum:album fromCollection:collection];
            
            CLLocation *albumlocation = [collection approximateLocation];
            NSLog(@"ADDING ALBUM NAME %@ for URL %@ LOCATION: %@", album.name, album.assetURL, albumlocation ? albumlocation.description : @"NOTHING");
            
            if(albumlocation!=nil) {
                LocationDataModel *model = [self saveLocationRecord:album.assetURL withDate:nil andLocation:albumlocation andAssetType:TYPE_ALBUM];
                if(model!=nil && album.photos.count > 0) {
                    BHPhoto *photo = [album.photos objectAtIndex:0];
                    //GET THE album and
                    [self.mapViewController addLocation:albumlocation withImage: photo.image  andTitle: album.name forModel:model containingURLS:album.photosURLs];
                }
                
            }
            
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
            
            
            //load all images in album
            [self parseImagesForAlbum:album fromCollection:collection];
            
            CLLocation *albumlocation = [collection approximateLocation];
            NSLog(@"ADDING ALBUM NAME %@ for URL %@ LOCATION: %@", album.name, album.assetURL, albumlocation ? albumlocation.description : @"NOTHING");
            
            if(albumlocation!=nil) {
                LocationDataModel *model = [self saveLocationRecord:album.assetURL withDate:nil andLocation:albumlocation andAssetType:TYPE_ALBUM];
                if(model!=nil && album.photos.count > 0) {
                    BHPhoto *photo = [album.photos objectAtIndex:0];
                    //GET THE album and
                    [self.mapViewController addLocation:albumlocation withImage: photo.image  andTitle: album.name forModel:model containingURLS:album.photosURLs];
                }
                
            }
            
        }
}

/**
 Fetch all the images from the album
 */
-(void) parseImagesForAlbum: (BHAlbum *) album fromCollection:(PHAssetCollection *) collection {
 
    PHImageManager *imageManager = [PHImageManager defaultManager];
    
    PHFetchOptions *options = [PHFetchOptions new];
    options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
    
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:collection options:options];
    NSInteger numOfPicturesInAlbum = (assets == nil) ? 0 : assets.count;
    
    //grab the album location if any
    CLLocation *albumlocation = [collection approximateLocation];
    
    NSLog(@"1 NUMBER OF PHOTOS FOR ALBUM %@ %lu", album.name, (unsigned long)numOfPicturesInAlbum);
    
    if(numOfPicturesInAlbum==0) {
        BHPhoto *photo = [BHPhoto photoWithImageData: [UIImage imageNamed:@"concrete"]];
        photo.imageURL = nil;
        [album addPhoto:photo];
    } else {
        
        //this is the max thumbnails i will read here, but i will grab all the thumbnails
        NSInteger maxNumPhotosPerAlbum = 3;
        //NSInteger processedImages = 0;
        //NSInteger processedImagesInYearlyAlbum = 0;
        __block NSInteger albumProcessedImages = 0;
        
        //parse image
        NSInteger *i = 0;
        //load the thumbnails for the first 3, and just add the url for the remaining
        for(PHAsset *asset in assets) {
              if(asset!=nil) {
                  //grab the location if any
                  CLLocation *imageLocation = asset.location;
                  //save the URL of the asset Photo
                  NSString *assetPhotoURL = asset.localIdentifier;
                  NSLog(@"asset photo url %@", asset.localIdentifier);
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
                      
                      NSLog(@"ADDING CUSTOM/FAKE ALBUM FOR YEAR %@",yearSTR);
                      [self.albumsYears addObject: yearSTR];
                      
                      BHAlbum *albumForYear = [[BHAlbum alloc] init];
                      albumForYear.photosURLs = [[NSMutableArray alloc] init];
                      albumForYear.assetURL = nil;
                      albumForYear.name = yearSTR;
            
                      [self.albums addObject:albumForYear]; //was album
                      
                      //save the reference to it
                      auxiliar = albumForYear;
                  
                      
                  }
                  
                  //------------------------------ TODO check repetitive code -----------------------------------------------
                   //check if this asset/image was already added to the current album (NOTE: this is not not counting the yearly album here)
                   
                   //INSERT THE PICTURE INTO THE NORMAL ALBUM
                   
                   //----------------------------------------------------------------------------------
                 [album.photosURLs addObject: assetPhotoURL];
                  
                  NSLog(@"2 - NUMBER OF PHOTOS FOR ALBUM %@ %lu", album.name, (unsigned long)album.photosURLs.count);
                  
                   //INSERT THE PICTURE INTO THE AUXILIAR/YEARLY ALBUM;
                   
                   //----------------------------------------------------------------------------------
                   if( auxiliar!=nil && [self albumContainsAssetURL:auxiliar assetURL:assetPhotoURL] == NO) {
                       [auxiliar.photosURLs addObject: assetPhotoURL];
                   }
                   //------------------------------------------------------------------------------------
                       
                  //ONLY process maximum of 3 images per album
                  if(albumProcessedImages < maxNumPhotosPerAlbum) {
                      
                      
                      PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
                      requestOptions.resizeMode   = PHImageRequestOptionsResizeModeExact;
                      requestOptions.networkAccessAllowed = true;
                      requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
                      requestOptions.synchronous = true;
                      
                      [imageManager requestImageForAsset:asset
                                             targetSize:CGSizeMake(125.0f, 125.0f)
                                            contentMode:PHImageContentModeDefault
                                                options:requestOptions
                                          resultHandler:^void(UIImage *thumbnail, NSDictionary *info) {
                                              if(thumbnail!=nil) {
                                                  
                                                  albumProcessedImages = albumProcessedImages +1;
                                                  
                                                  //add the photo and reload the collection view
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      
                                                      BHPhoto *photo = [BHPhoto photoWithImageData: thumbnail];
                                                      photo.imageURL = assetPhotoURL;
                                                      [album addPhoto:photo];
                                                      
                                                      //also add to the auxiliar album
                                                      if(auxiliar!=nil && auxiliar.photos.count < maxNumPhotosPerAlbum) {
                                                          
                                                          BHPhoto *photo = [BHPhoto photoWithImageData: thumbnail];
                                                          photo.imageURL = assetPhotoURL;
                                                          [auxiliar addPhoto:photo];
                                                      }
                                                      
                                                      //reload collectiuon view
                                                      [self.collectionView reloadData];
                                                      
                                                      
                                                  });
                                                  
                                                  
                                                  
                                                 //save the location of the record on the location model
      
                                                  if(imageLocation==nil && albumlocation!=nil) {
                                                      //SAVE THE RECORD WITH THE ALBUM LOCATION
                                                      NSLog(@"SAVING %@ with album location %@", assetPhotoURL, albumlocation.description);
                                                      LocationDataModel *model = [self saveLocationRecord: assetPhotoURL withDate:theDate andLocation:albumlocation andAssetType:TYPE_ALBUM];
                                                      
                                                      if(model!=nil) {
                                                          NSLog(@"Adding image location to the map from album location");
                                                          NSMutableArray *urls = [[NSMutableArray alloc] initWithObjects:assetPhotoURL, nil];
                                                          [self.mapViewController addLocation:albumlocation withImage: thumbnail  andTitle: [NSString stringWithFormat:@"%d",i] forModel:model containingURLS:urls];
                                                      }
                                                      
                                                  }
                                                  else if(imageLocation!=nil) {
                                                      //SAVE THE RECORD (not saving any images or pics) WITH THE PHOTO LOCATION
                                                      //There is an exif cordinate???
                                                      //if we have location data, add the annotation to the map
                                                      
                                                      NSLog(@"SAVING %@ with photo own location %@",assetPhotoURL,imageLocation.description);
                                                      LocationDataModel *model = [self saveLocationRecord:assetPhotoURL withDate:theDate andLocation:imageLocation andAssetType:TYPE_PHOTO];
                                                    
                                                      if(model!=nil) {
                                                          NSLog(@"Adding image location to the map from exif 1");
                                                          NSMutableArray *urls = [[NSMutableArray alloc] initWithObjects:assetPhotoURL, nil];
                                                          [self.mapViewController addLocation:imageLocation withImage: thumbnail  andTitle: [NSString stringWithFormat:@"IMG-%d",i] forModel:model containingURLS:urls];
                                                      }
                                                      
                                                  }
                                              }
                                              
                                          }];

                      
                  }//end if album processed images < 3
                    
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
        NSLog(@"number of items for album %@ is  %ld",album.name, (unsigned long)album.photos.count);
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
    
    if(row < self.albums.count) {
   
        BHAlbum *album = self.albums[row];
        NSInteger tag = row;
        
        if(photoIndex < album.photos.count) {
            //photoIndex gives me the album
            BHPhoto *photo = album.photos[photoIndex];
            
            // load photo images in the background
            //__weak BHCollectionViewController *weakSelf = self;
            //NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
                
                //UIImage *image = [UIImage imageWithCGImage:[photo.rawImage fullScreenImage]];
                UIImage *image = [photo image];
                
                //dispatch_async(dispatch_get_main_queue(), ^{
                    // then set them via the main queue if the cell is still visible.
                    //if ([weakSelf.collectionView.indexPathsForVisibleItems containsObject:indexPath]) {
                        
                        //BHAlbumPhotoCell *cell =
                        //(BHAlbumPhotoCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
               
                        photoCell.imageView.image = image;
                        photoCell.imageView.userInteractionEnabled = YES;
                        photoCell.imageView.tag = tag;
                        UITapGestureRecognizer *tapGesture =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapAlbumWithGesture:)];
                        [photoCell.imageView addGestureRecognizer:tapGesture];
  
                    //}
                //});
            //}];
            
            //operation.queuePriority = (indexPath.item == 0) ?
            //NSOperationQueuePriorityHigh : NSOperationQueuePriorityNormal;
            
            //[self.thumbnailQueue addOperation:operation];
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
    
    
    if(tag<albums.count) {
        //valid index
        BHAlbum *selectedOne = [albums objectAtIndex:tag];
        
        //TODO IT IS HERE (i am not copying everything??)
        albumViewController.title = selectedOne.name;
        albumViewController.selectedAlbum = selectedOne;
        albumViewController.selectedAlbumIndex = tag;
        
    }
    
 
    NSMutableArray *arrayOfNames = [[NSMutableArray alloc] init];
    for(BHAlbum *album in albums) {
        NSLog(@"adding ALBUM %@",album);
        [arrayOfNames addObject:album.name];
    }
    [albumViewController addAlbumsNamesFromArray:arrayOfNames];
    
    //remove the one on the left , leaving only the back button
    albumViewController.navigationItem.leftBarButtonItem=nil;
    [self.navigationController pushViewController: albumViewController animated:NO];
  
    
    
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


@end
