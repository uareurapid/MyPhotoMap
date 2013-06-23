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
@synthesize location;
@synthesize mapViewController;
@synthesize managedObjectContext;
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
                                                          style:UIBarButtonSystemItemAdd target:self action:@selector(addAlbumClicked:)];
       
        self.navigationItem.leftBarButtonItem = left;
        
        
        
        databaseRecords = [[NSMutableArray alloc] init];
        
        
       
      
    }
    return self;
    
}
//add the button
-(void ) viewWillAppear:(BOOL)animated {
    NSLog(@"will appear");
    if(albums.count > 0) { //have been here already
        
        [self readCameraRoll];
    }
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
    
    
    
    //load existing data on database
    [self fetchLocationRecords];
    
    
    
    [self readNumberOfExistingAlbums];
    [self readCameraRoll];
    
    
    
}

//get all the records from db
- (void) fetchLocationRecords{
    [databaseRecords removeAllObjects];
    databaseRecords = [CoreDataUtils fetchLocationRecordsFromDatabase];
   
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
    
    ALAssetsLibrary *assetsLib = [[ALAssetsLibrary alloc] init];
    numExistingAlbums =0;

    ////search all photo albums in the library
    [assetsLib enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if(group!=nil) {
            if([group valueForProperty:ALAssetsGroupPropertyName]!=nil) {
                numExistingAlbums = numExistingAlbums+1;
            }
        }
    
     }
     
          failureBlock:^(NSError *error)  {
              NSLog(@"Error getting the albums");
           }
     
     ] ;
}

-(void) reloadAlbumsInfo {
    [self readNumberOfExistingAlbums];
    [self.collectionView reloadData];
}

//creates a new Album if not exists
-(void) createNewAlbum: (NSString*) albumName{
    
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
                                          
                                      });
                                  }
             
                                  failureBlock:^(NSError *error)  {
                                     NSLog(@"Error Adding the album %@",albumName);
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

//will read all the albums on th card and their contents
- (void) readCameraRoll {
    
    
    //UIImage* __block image = [[UIImage alloc] init];
    ALAssetsLibrary *assetsLib = [[ALAssetsLibrary alloc] init];

    
    //this is the max thumbnails i will read here, but i will grab all the thumbnails
    NSInteger maxNumPhotosPerAlbum = 3;
    __block NSInteger processedImages = 0;
    
    //clear annotations
    [mapViewController removeAnnotations];
    
    [assetsLib enumerateGroupsWithTypes:ALAssetsGroupAll
     
                      usingBlock:^(ALAssetsGroup *group, BOOL *stop)
     {
        
         NSString *name = [group valueForProperty:ALAssetsGroupPropertyName];
         
         if(name!=nil) {
 
             BHAlbum *album = [self albumsContainsName:name];
             NSInteger numOfAssets = [group numberOfAssets];
             
             
             if( album == nil) {
                 
                 album = [[BHAlbum alloc] init];
                 album.photosURLs = [[NSMutableArray alloc] init];
                 album.assetURL = [group valueForProperty:ALAssetsGroupPropertyURL];
                 album.name = name;
                 [self.albums addObject:album];
                 
                 //get only the first 3 images thumbnails to display
                 
                 
                 album.photosCount = numOfAssets;
                 
                 //album doesn´t have any photo, add default empty one
                 if(numOfAssets==0) {
                     BHPhoto *photo = [BHPhoto photoWithImageData: [UIImage imageNamed:@"concrete"]];
                     [album addPhoto:photo];
                 }
             
             }
      
      
             //à segunda
             
             for(int i = 0; i < numOfAssets; i++) {//just grab the first image
                 
                 
                 
                     [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:i] options:0 usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop)
                      {
                          if (result != nil) {
                              
                              
                              NSString *type = [result valueForProperty:ALAssetPropertyType];//only images for now
                              CLLocation *imageLocation = [result valueForProperty:ALAssetPropertyLocation];
                              
                              
                              if([type isEqualToString:ALAssetTypePhoto]) {
                                  
                                  //save the URL of the asset Photo
                                  NSURL *url = [result valueForProperty:ALAssetPropertyAssetURL];
                                  NSDate *theDate = [result valueForProperty:ALAssetPropertyDate];
                                  NSString *_location = [result valueForProperty:ALAssetPropertyLocation];
                                  NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:theDate];
                                  
                                  NSInteger year = components.year;
                                  NSString *yearSTR = [NSString stringWithFormat:@"%d",year];
                                  if(! [albumsYears containsObject:yearSTR]) {
                                      
                                      NSLog(@"adding year %@",yearSTR);
                                      [albumsYears addObject: yearSTR];
                                      
                                      BHAlbum *albumYear = [[BHAlbum alloc] init];
                                      albumYear.photosURLs = [[NSMutableArray alloc] init];
                                      albumYear.assetURL = nil;
                                      albumYear.name = yearSTR;
                                      [self.albums addObject:album];
                                  }
                                  
                                  NSLog(@"Location is: %@ with year: %d",_location,components.year);
                                  
                                  //check if this asset was already added
                                  if( [self albumContainsAssetURL:album assetURL:url] == NO) {
                                 
                                      [album.photosURLs addObject: url];
                                      //get the thumbnail
                                      __block UIImage *thumbnail = [UIImage imageWithCGImage:[result thumbnail]];
                                      
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

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    NSLog(@"sections %d",self.albums.count);
    return self.albums.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    BHAlbum *album = self.albums[section];
    NSLog(@"number items %d %d",section,album.photos.count);
    return album.photos.count;
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
            //gives me the album
            BHPhoto *photo = album.photos[photoIndex];
            
            // load photo images in the background
            __weak BHCollectionViewController *weakSelf = self;
            NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
                
                //UIImage *image = [UIImage imageWithCGImage:[photo.rawImage fullScreenImage]];
                UIImage *image = [photo image];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    // then set them via the main queue if the cell is still visible.
                    if ([weakSelf.collectionView.indexPathsForVisibleItems containsObject:indexPath]) {
                        
                        BHAlbumPhotoCell *cell =
                        (BHAlbumPhotoCell *)[weakSelf.collectionView cellForItemAtIndexPath:indexPath];
               
                        cell.imageView.image = image;
                        cell.imageView.userInteractionEnabled = YES;
                        cell.imageView.tag = tag;
                        UITapGestureRecognizer *tapGesture =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapAlbumWithGesture:)];
                        [cell.imageView addGestureRecognizer:tapGesture];
  
                    }
                });
            }];
            
            operation.queuePriority = (indexPath.item == 0) ?
            NSOperationQueuePriorityHigh : NSOperationQueuePriorityNormal;
            
            [self.thumbnailQueue addOperation:operation];
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
        [self createNewAlbum:albumName];
    }
    
}


//clicked on a empty album and show all the pics inside (if any)
- (void)didTapAlbumWithGesture:(UITapGestureRecognizer *)tapGesture{
   
    UIImageView *imageView = (UIImageView*)tapGesture.view;
    NSInteger tag = imageView.tag;
    
    
    if(tag<albums.count) {
        //valid index
        BHAlbum *selectedOne = [albums objectAtIndex:tag];
        albumViewController.title = selectedOne.name;
        albumViewController.selectedAlbum = selectedOne;
        
    }
    
    // Create the item to share (in this example, a url)
    /*
	NSURL *url = [NSURL URLWithString:@"http://getsharekit.com"];
	SHKItem *item = [SHKItem URL:url title:@"ShareKit is Awesome!"];
    
	// Get the ShareKit action sheet
	SHKActionSheet *actionSheet = [SHKActionSheet actionSheetForItem:item];
    
	// Display the action sheet
	[actionSheet showInView:imageView];
     
     */
    //BHAlbum *album = albums[imageView.tag];
    
    
    //[album.photos removeAllObjects];
    
    //[self readAlbum:album.name withAlbum:album];
    
    
    //NSLog(@"album size at the end %d",album.photos.count);
    //albumView.album = album;
    
    NSMutableArray *arrayOfNames = [[NSMutableArray alloc] init];
    for(BHAlbum *album in albums) {
        NSLog(@"adding ALBUM %@",album);
        [arrayOfNames addObject:album.name];
    }
    [albumViewController addAlbumsNamesFromArray:arrayOfNames];
    
    //remove the one on the left , leaving only the back button
    albumViewController.navigationItem.leftBarButtonItem=nil;
    [albumViewController readAlbumThumbnails];
    [self.navigationController pushViewController: albumViewController animated:YES];
  
    
    
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
