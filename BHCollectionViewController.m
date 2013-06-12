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

@synthesize albums,albumView;
@synthesize assetsURLs;
@synthesize tabBarController;
@synthesize numExistingAlbums;
@synthesize albumTextField;
@synthesize addAlbumButton,navController;
@synthesize location;
@synthesize mapViewController;

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle {
    self = [super initWithNibName:nibName bundle:nibBundle];
    if(self) {
        albums = [NSMutableArray array];
        assetsURLs = [[NSMutableArray alloc] init];
        self.title = @"Your Albums";
        [self initTextFieldNewAlbum];
        
        addAlbumButton = [[UIBarButtonItem alloc] initWithTitle:@"Settings"
                          style:UIBarButtonItemStyleDone target:self action:@selector(settingsClicked:)];
        
        self.navigationItem.rightBarButtonItem = addAlbumButton;
        
        
        
        UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithTitle:@"Add"
                                                          style:UIBarButtonSystemItemAdd target:self action:@selector(addAlbumClicked:)];
       
        self.navigationItem.leftBarButtonItem = left;
        
        
        
       
        
        
       
      
    }
    return self;
    
}
//add the button
-(void ) viewWillAppear:(BOOL)animated {
    //self.navigationItem.rightBarButtonItem.enabled = YES;
    //self.navigationItem.rightBarButtonItem.title = @"Settings";
    NSLog(@"collectio map is: %@",mapViewController);
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
    
    [self readExistingAlbums];
    [self readCameraRoll];
    
    
}
/*
 2013-06-05 16:53:06.517 CollectionViewTutorial[824:907] passed this
 2013-06-05 16:53:06.853 CollectionViewTutorial[824:907] Adding album : Teste
 2013-06-05 16:53:06.886 CollectionViewTutorial[824:907] Adding image ALAsset - Type:Photo, URLs:assets-library://asset/asset.JPG?id=40768DC0-5912-40EE-B1E5-8E8B9E32247B&ext=JPG
 2013-06-05 16:53:07.184 CollectionViewTutorial[824:907] Adding album : Camera Roll
 2013-06-05 16:53:07.210 CollectionViewTutorial[824:907] Adding image ALAsset - Type:Photo, URLs:assets-library://asset/asset.JPG?id=87A1227B-84C1-4E5F-89BB-FD73F4D02421&ext=JPG
 2013-06-05 16:53:07.478 CollectionViewTutorial[824:907] Adding image ALAsset - Type:Photo, URLs:assets-library://asset/asset.JPG?id=9FED9ACE-6876-40EB-8546-1569D1BE446A&ext=JPG
 
 */

//the new Album text field name
-(void) initTextFieldNewAlbum {
  /*
    albumTextField = [[UITextField alloc] init];
    [albumTextField setBackgroundColor:[UIColor whiteColor]];
    albumTextField.delegate = self;
    albumTextField.borderStyle = UITextBorderStyleLine;
    albumTextField.frame = CGRectMake(15, 75, 255, 30);
    albumTextField.font = [UIFont fontWithName:@"ArialMT" size:20];
    albumTextField.placeholder = @"Album Name";
    //textField.textAlignment = UITextAlignmentCenter; deprecated in ios 6
    albumTextField.keyboardAppearance = UIKeyboardAppearanceAlert;
    [albumTextField becomeFirstResponder];
   */
}


-(void) readExistingAlbums{
    
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
    [self readExistingAlbums];
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
 
             BHAlbum *album = [[BHAlbum alloc] init];
             album.photosURLs = [[NSMutableArray alloc] init];
             album.name = name;
             [self.albums addObject:album];
             //NSLog(@"Adding album : %@, %d",album.name, self.albums.count);
    
             //get only the first 3 images thumbnails to display
 
             NSInteger numOfAssets = [group numberOfAssets];
             album.photosCount = numOfAssets;
             
             //album doesn´t have any photo
             if(numOfAssets==0) {
                 BHPhoto *photo = [BHPhoto photoWithImageData: [UIImage imageNamed:@"concrete"]];
                 [album addPhoto:photo];
             }
             //else
             for(int i = 0; i < numOfAssets; i++) {//just grab the first image
                 
                 
                 
                     [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:i] options:0 usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop)
                      {
                          if (result != nil) {
                              
                              
                              NSString *type = [result valueForProperty:ALAssetPropertyType];//only images for now
                              CLLocation *imageLocation = [result valueForProperty:ALAssetPropertyLocation];
                              
                              
                              if([type isEqualToString:ALAssetTypePhoto]) {
                                  
                                  //save the URL of the asset Photo
                                  [album.photosURLs addObject: [result valueForProperty:ALAssetPropertyAssetURL]];
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
                                      NSLog(@"Will ADD ONE WITH LOCATION %@ TO THE MAP NOW",imageLocation);
                                      //if we have location data, add the annotation to the map
                                      [mapViewController addLocation:imageLocation withImage: thumbnail  andTitle: [NSString stringWithFormat:@"%d",i]];
                                  }
                                  
                                  
            
                                  
                              }
                              
                              
                          }
                      
                      
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
    //NSLog(@"Returning numberOfSectionsInCollectionView %d", self.albums.count);
    return self.albums.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    BHAlbum *album = self.albums[section];
    
     //NSLog(@"Returning numberOfItemsInSection %d",album.photos.count);
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
                        
                       // if([album.name isEqualToString:@"Click + to add"]) {
                            
                            //show a new album dialog
                         //   UITapGestureRecognizer *tapGesture =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapEmptyAlbumWithGesture:)];
                         //   [cell.imageView addGestureRecognizer:tapGesture];
                            
                       // }
                       // else {
                            //normal tap gesture
                            UITapGestureRecognizer *tapGesture =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapAlbumWithGesture:)];
                            [cell.imageView addGestureRecognizer:tapGesture];
                       // }
                        
                        
                        
                        
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
    //SearchLocationViewController *view = [[SearchLocationViewController alloc] initWithNibName:@"SearchLocationViewController" bundle:nil];
    //[self.navigationController pushViewController:view animated:YES];
}

//the delegate for the new Album
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(buttonIndex==1) { //0 - cancel, 1 - save
        NSString *albumName = [alertView textFieldAtIndex:0].text;
        [self createNewAlbum:albumName];
    }
    
    
    /*
    NSString* detailString = textField.text;
    NSLog(@"String is: %@", detailString); //Put it on the debugger
    if ([textField.text length] <= 0 || buttonIndex == 0){
        return; //If cancel or 0 length string the string doesn't matter
    }
    if (buttonIndex == 1) {
        ...
        
    }*/
}


//clicked on a non empty album and show all the pics
- (void)didTapAlbumWithGesture:(UITapGestureRecognizer *)tapGesture{
   
    UIImageView *imageView = (UIImageView*)tapGesture.view;
    NSInteger tag = imageView.tag;
    
    NSLog(@"selected album is %d",tag);
    if(tag<albums.count) {
        //valid index
        BHAlbum *selectedOne = [albums objectAtIndex:tag];
        albumView.title = selectedOne.name;
        albumView.selectedAlbum = selectedOne;
        
        
        //[selectedOne.photos removeAllObjects]; //remove the 3 photos (or less) used only as cover
        //[albumView.albums removeAllObjects]; //each photo of the selectedOne will be an album on its own, on the albumView
        //[albumView.albums addObject:selectedOne];//just add this one
        //albumView.title = selectedOne.name;
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
    
    
    //remove the one on the left , leaving only the back button
    albumView.navigationItem.leftBarButtonItem=nil;
    [albumView readAlbumThumbnails];
    [self.navigationController pushViewController: albumView animated:YES];
  
    
    
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
