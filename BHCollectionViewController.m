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
//add the button
-(void ) viewWillAppear:(BOOL)animated {
    NSLog(@"will appear");
    //if(albums.count > 0) { //have been here already
        
    //    [self readCameraRoll];
    //}
}

//put the add album buttom again
-(void) viewWillDisappear:(BOOL)animated {
 
    //self.navigationItem.rightBarButtonItem.enabled = NO;
    //self.navigationItem.rightBarButtonItem.title = @"";
    
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
        if (error.code == ALAssetsLibraryAccessUserDeniedError) {
            NSLog(@"user denied access, code: %zd", error.code);
        } else {
            NSLog(@"Other error code: %zd", error.code);
        }
    }];
    
    //check permissions
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    if (status != ALAuthorizationStatusAuthorized) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Attention" message:@"Please give this app permission to access your photo library in your settings app!" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    //clear annotations
    [mapViewController removeAnnotations];
    
    //is just readin the numbers???
    [self readNumberOfExistingAlbums];

    //first get all the stuff on the device
    [self readCameraRoll];
    
    //and now load all existing data from database
    [self fetchLocationRecords];
    
    
    
}

-(void) viewDidAppear:(BOOL)animated{
    NSLog(@"apperead");
}

//get all the records from db
- (void) fetchLocationRecords{
    [databaseRecords removeAllObjects];
    databaseRecords = [CoreDataUtils fetchLocationRecordsFromDatabase];
    
    if (!databaseRecords) {
        // Handle the error.
        // This is a serious error and should advise the user to restart the application
    }
    else {
        NSLog(@"LOADED %ld RECorDS FroM DB",databaseRecords.count);
        for(LocationDataModel *entity in databaseRecords) {
            //load the thumbnail
            if(entity.assetURL!=nil) {
                [self loadAssetInfoFromDataModel:entity];
            }
        }
    }
    

   
}

#pragma asset stuff
-(void) loadAssetInfoFromDataModel:(LocationDataModel*)model {
    //NSLog(@"Loading asset for model with assetURL %@: ",model.assetURL);
    
    //if it is an album found the match in the complete array, and get the list of photos
    NSMutableArray *photos = nil;
    if([model.type isEqualToString:TYPE_ALBUM]) {
        for(BHAlbum *album in self.albums) {
            if([[album.assetURL absoluteString] isEqualToString:model.assetURL]) {
                photos = [[NSMutableArray alloc] initWithCapacity:album.photosCount];
                [photos addObjectsFromArray:album.photosURLs];
            }
        }
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
                
                //TODO add the full size here:
                [mapViewController addLocation:locationCL withImage:image andTitle:@"other test" forModel:model containingURLS:photos];
                
                //[mapViewController addLocation:locationCL withThumbnail:image withImage:imageFinal andTitle:@"other test" forModel:model containingURLS:photos];
                //NSLog(@"Adding location to the map, read from database");
                
            });
        }
        
        
    };
    
    ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror){
        NSLog(@"Failed to get image for assetURL %@: ",model.assetURL);
        //failed to get image.
    };
    
    ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
    [assetslibrary assetForURL: [NSURL URLWithString: model.assetURL ] resultBlock:resultblock failureBlock:failureblock];
}

/*
 2013-06-05 16:53:06.517 CollectionViewTutorial[824:907] passed this
 2013-06-05 16:53:06.853 CollectionViewTutorial[824:907] Adding album : Teste
 2013-06-05 16:53:06.886 CollectionViewTutorial[824:907] Adding image ALAsset - Type:Photo, URLs:assets-library://asset/asset.JPG?id=40768DC0-5912-40EE-B1E5-8E8B9E32247B&ext=JPG
 2013-06-05 16:53:07.184 CollectionViewTutorial[824:907] Adding album : Camera Roll
 2013-06-05 16:53:07.210 CollectionViewTutorial[824:907] Adding image ALAsset - Type:Photo, URLs:assets-library://asset/asset.JPG?id=87A1227B-84C1-4E5F-89BB-FD73F4D02421&ext=JPG
 2013-06-05 16:53:07.478 CollectionViewTutorial[824:907] Adding image ALAsset - Type:Photo, URLs:assets-library://asset/asset.JPG?id=9FED9ACE-6876-40EB-8546-1569D1BE446A&ext=JPG
 
 */


-(void) readNumberOfExistingAlbums{
    /*
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
     
     ] ;*/
}

-(void) reloadAlbumsInfo {
    [self readNumberOfExistingAlbums];
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

-(void)saveLocationRecord:(NSURL*)assetURL withDate:(NSDate*) date andLocation:(CLLocation*) imageLocation {
    
    NSMutableArray *results = [CoreDataUtils fetchLocationRecordsFromDatabaseWithAssetURL:[assetURL absoluteString]];
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
        
        [locationObject setName: [assetURL absoluteString]];
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
        
        if([[assetURL absoluteString] rangeOfString:@"group"].location==NSNotFound)
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
        
        locationObject.assetURL = [assetURL absoluteString];
        locationObject.thumbnailURL = [assetURL absoluteString];//need to save it as a string
        
        
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
            NSLog(@"#####Added record %@, to data model",[assetURL absoluteString]);
            //    [self loadAssetInfoFromDataModel: locationObject isAlbum: isAlbumType];
        }
    }
    
    
    
    
}

//----------------------------------------



//will read all the albums on th card and their contents
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
 
             BHAlbum *album = [self albumsContainsName:name];
             //get the number of pictures inside each album
             NSInteger numOfAssets = [group numberOfAssets];
             
             //ALBUM DOES NOT EXIST YET!!
             if( album == nil) {
                 
                 album = [[BHAlbum alloc] init];
                 album.photosURLs = [[NSMutableArray alloc] init];
                 album.assetURL = [group valueForProperty:ALAssetsGroupPropertyURL];
                 album.name = name;
                 NSLog(@"ADDING ALBUM NAME %@ for URL %@", album.name, album.assetURL);
                 [self.albums addObject:album];
                 
                 //get only the first 3 images thumbnails to display
                 
                 
                 album.photosCount = numOfAssets;
                 
                 //album doesn´t have any photo, add a default empty one
                 if(numOfAssets==0) {
                     BHPhoto *photo = [BHPhoto photoWithImageData: [UIImage imageNamed:@"concrete"]];
                     photo.imageURL = nil;
                     [album addPhoto:photo];
                 }
                 
                 //SAVE THE MODEL
                 [self saveLocationRecord:album.assetURL withDate:nil andLocation:nil];
             
             }
      
      
             //à segunda
             
             for(int i = 0; i < numOfAssets; i++) {//just grab the first image
                 
                 
                     //start sorting the image assets
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
                                  NSString *_location = [result valueForProperty:ALAssetPropertyLocation];
                                  NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:theDate];
                                  
                                  
                                  //SAVE THE RECORD (not saving any images or pics)
                                  [self saveLocationRecord:assetPhotoURL withDate:theDate andLocation:imageLocation];
                                  
                                  NSInteger year = components.year;
                                  NSString *yearSTR = [NSString stringWithFormat:@"%ld",(long)year];
                                  
                                  //check if the existing list of albums contains the year of this photo?
                                  BHAlbum *aux = [self albumsContainsName:yearSTR];
                                  
                                  //these are FAKE yearly albums, not on the device itself
                                  if(! [albumsYears containsObject:yearSTR] && aux==nil) {
                                      
                                      NSLog(@"ADDING CUSTOM/FAKE ALBUM FOR YEAR %@",yearSTR);
                                      [albumsYears addObject: yearSTR];
                                      
                                      BHAlbum *albumYear = [[BHAlbum alloc] init];
                                      albumYear.photosURLs = [[NSMutableArray alloc] init];
                                      albumYear.assetURL = nil;
                                      albumYear.name = yearSTR;
                                      
                                      
                                      //check if we have an album on our collection with the same title (year)
                                      //if not we add this fake album now
                                      //NSLog(@"adding album for year %ld",(long)components.year);
                                      [self.albums addObject:albumYear]; //was album
                                      
                                      //save the reference to it
                                      auxiliar = albumYear;
                                  
                                      
                                  }
                                  else if(aux!=nil) {
                                      //NSLog(@"album year already exists");
                                      //already exists this FAKE album
                                      auxiliar = aux;
                                  }
                                  
                                  //NSLog(@"Location is: %@ with year: %ld",_location,(long)components.year);
                                  
                                  //------------------------------ TODO check repetitive code -----------------------------------------------
                                  //check if this asset/image was already added to the current album (NOTE: this is not not counting the yearly album here)
                                  
                                  //INSERT THE PICTURE INTO THE NORMAL ALBUM
                                  //NSLog(@"INSERT THE PICTURE INTO THE NORMAL ALBUM : %@",album.name);
                                  if( [self albumContainsAssetURL:album assetURL:assetPhotoURL] == NO) {
                                 
                                      [album.photosURLs addObject: assetPhotoURL];
                                      //get the thumbnail
                                      __block UIImage *thumbnail = [UIImage imageWithCGImage:[result thumbnail]];
                                      
                                      //ONLY process maximum of 3 images per album
                                      if(albumProcessedImages < maxNumPhotosPerAlbum) {
                                          albumProcessedImages = albumProcessedImages +1;
                                          NSLog(@"Processed image %ld for album name: %@", albumProcessedImages, name);
                                          
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              
                                              BHPhoto *photo = [BHPhoto photoWithImageData: thumbnail];
                                              photo.imageURL = assetPhotoURL;
                                              [album addPhoto:photo];
                                              [self.collectionView reloadData];
                                              
                                              
                                          });
                                      }
                                      //for all images
                                      if(imageLocation!=nil) {
                                          //There is an exif cordinate???
                                          //if we have location data, add the annotation to the map
                                          [mapViewController addLocation:imageLocation withImage: thumbnail  andTitle: [NSString stringWithFormat:@"%d",i] forModel:nil containingURLS:nil];
                                      }
                                  }
                                  //----------------------------------------------------------------------------------
                                  //INSERT THE PICTURE INTO THE AUXILIAR ALBUM
                                  //NSLog(@"INSERT THE PICTURE INTO THE AUXILIAR/YEARLY ALBUM : %@",auxiliar.name);
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
                                      //for all images
                                      if(imageLocation!=nil) {
                                          //if we have location data, add the annotation to the map
                                          [mapViewController addLocation:imageLocation withImage: thumbnail  andTitle: [NSString stringWithFormat:@"%d",i] forModel:nil containingURLS:nil];
                                      }
                                  }
                                  //------------------------------------------------------------------------------------
                                  
                                  //else already exists, skipp it 

                                  
                              }
                              
                              
                          }
                      
                          //if(processedImages >=  (maxNumPhotosPerAlbum * self.albums.count) ) {
                            //  return ; //already did all the job needed
                          //}
                      
                      }];
                 
             } //end for LOOP
                
             
         }//end if name !=nil
         
         
     }
     
                    failureBlock:^(NSError *error)  {
                            NSLog(@"Error reading phone images");
                            // User did not allow access to library
                            // .. handle error 
                    }
     
     ] ;

    
}

/*-(void) insertPictureOnAlbum: (BHAlbum *) album withURL:(NSURL *)url andThumbnail: (CGImageRef thumbnail) {
    
    if( [self albumContainsAssetURL:album assetURL:url] == NO) {
        
        [album.photosURLs addObject: url];
        //get the thumbnail
        __block UIImage *thumbnail = [UIImage imageWithCGImage: thumbnail];
        
        //ONLY process maximum of 3 images per album
        if(processedImages <  (maxNumPhotosPerAlbum * self.albums.count) ) {
            processedImages = processedImages +1;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                BHPhoto *photo = [BHPhoto photoWithImageData: thumbnail];
                [album addPhoto:photo];
                [self.collectionView reloadData];
                
                
            });
        }
        //for all images
        if(imageLocation!=nil) {
            //if we have location data, add the annotation to the map
            [mapViewController addLocation:imageLocation withImage: thumbnail  andTitle: [NSString stringWithFormat:@"%d",i]];
        }
    }
}*/
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
-(BOOL) albumContainsAssetURL: (BHAlbum *)album assetURL: (NSURL*) url {
    for(NSURL * theURL in album.photosURLs) {
        NSString *toString = [theURL absoluteString];
        NSString *urlToString = [url absoluteString];
        if([urlToString isEqualToString:toString]) {
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
