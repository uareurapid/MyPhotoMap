//
//  MYAlbumViewController.m
//  CollectionViewTutorial
//
//  Created by Paulo Cristo on 6/6/13.
//  Copyright (c) 2013 Bryan Hansen. All rights reserved.
//

#import "MYAlbumViewController.h"

#import "AlbumOptionsTableViewController.h"

@interface MYAlbumViewController ()

@end



@implementation MYAlbumViewController

//@synthesize album;//the selected album
//@synthesize albumPhotos;//the miniatures of the albums, which will be albums of just one pic
@synthesize detailViewController;
@synthesize listAlbumsAvailableController;

@synthesize selectedAlbum;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //albumPhotos = [[NSMutableArray alloc] init];
        detailViewController = [[PhotoDetailViewController alloc] initWithNibName:@"PhotoDetailViewController" bundle:nil];
        
        
        //add the settings button
        UIBarButtonItem *addAlbumButton = [[UIBarButtonItem alloc] initWithTitle:@"Actions"
                                                                           style:UIBarButtonItemStyleDone target:self action:@selector(settingsClicked:)];
        self.navigationItem.rightBarButtonItem = addAlbumButton;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
}

-(void) viewWillAppear:(BOOL)animated {
    
    NSLog(@"Album map is: %@",self.mapViewController);
    
    //self.navigationItem.rightBarButtonItem=nil;
    
    
    //UIBarButtonItem *addAlbumButton = [[UIBarButtonItem alloc] initWithTitle:@"Settings"
     //                                                 style:UIBarButtonItemStyleDone target:self action:@selector(settingsClicked:)];
    
    
    //UIBarButtonItem *takePicture = [[UIBarButtonItem alloc] initWithTitle:@"Take photo"
    //                                                                style:UIBarButtonItemStyleDone target:self action:@selector(takePhoto:)];
    
    
    //self.navigationItem.rightBarButtonItem = takePicture;
    
    //self.navigationItem.rightBarButtonItem = addAlbumButton;
    
    
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
-(IBAction)editLocation:(id)sender {
    SearchLocationViewController *view = [[SearchLocationViewController alloc] initWithNibName:@"SearchLocationViewController" bundle:nil];
    view.assetURL = assetURL; //set the asset url
    view.image = thumbnail;
    [self.navigationController pushViewController:view animated:YES];
}*/


-(IBAction)settingsClicked:(id) sender{
  //will show a lit with two options
    //edit location and take photo
    AlbumOptionsTableViewController *optionsController = [[AlbumOptionsTableViewController alloc] initWithNibName:@"AlbumOptionsTableViewController" bundle:nil controller:self];
    [self.navigationController pushViewController:optionsController animated:YES];
}


#pragma take photo selector
- (IBAction)takePhoto:(id)sender {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
	imagePickerController.editing = YES;
    imagePickerController.delegate = (id)self;
    
    [self presentModalViewController:imagePickerController animated:YES];
}

-(IBAction)addLocation:(id)sender {
    SearchLocationViewController *view = [[SearchLocationViewController alloc] initWithNibName:@"SearchLocationViewController" bundle:nil];
    view.navigationItem.rightBarButtonItem = nil;
    view.navigationItem.leftBarButtonItem = nil;
    view.assetURL = selectedAlbum.assetURL; //set the asset url
    if(selectedAlbum.photos.count>0) {
        BHPhoto *photo = [selectedAlbum.photos objectAtIndex:0];
        view.image = photo.image;
    }
    
    [self.navigationController pushViewController:view animated:YES];
}


#pragma mark Image picker delegate methdos
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo

{
    //NSLog(@"Tryig to save with location data!");
   // [self saveImage:image withInfo:editingInfo];
    

    
    //listAlbums.albumsNames = [[NSArray alloc] initWithObjects:@"one",@"two", nil];
    //[self.navigationController pushViewController:listAlbums animated:NO];
    
   // [self presentViewController:listAlbums animated:YES completion:^{[listAlbums saveOnAlbum:image];}];
    
    //[[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentModalViewController:listAlbums animated:YES];
    
    [picker dismissViewControllerAnimated:NO
                               completion: ^{[self showAlbumsList: image editingInfo:editingInfo];}];
}

- (void) showAlbumsList:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    
    
    
    NSMutableArray *albumsAvailable = [[NSMutableArray alloc]init];
    for(BHAlbum *album in self.albums) {
        NSString *name = album.name;
        [albumsAvailable addObject:name];
    }

    listAlbumsAvailableController =
    [[AlbumsListViewController alloc] initWithNibName:@"AlbumsListViewController"
                                               bundle:nil predefined:selectedAlbum.name available:albumsAvailable];
    //pass the necessary info
    listAlbumsAvailableController.imageToSave = image;
    listAlbumsAvailableController.imageInfo = editingInfo;
    listAlbumsAvailableController.photoLocation = self.location;
    
    [self.navigationController pushViewController:listAlbumsAvailableController animated:NO];
}


//save the image along with their metadata info
- (void) saveImage:(UIImage *)imageToSave withInfo:(NSDictionary *)info
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    // Get the image metadata (EXIF & TIFF)
    NSMutableDictionary * imageMetadata = [[info objectForKey:UIImagePickerControllerMediaMetadata] mutableCopy];
    
    if(imageMetadata==nil){
        //NSLog(@"this one is nil");
        imageMetadata = [[NSMutableDictionary alloc]init];
    }
    // add GPS data
    // need a location here
    if ( self.location!=nil ) {
        NSDictionary *locationInfo = [self getGPSDictionaryForLocation:self.location];
        NSLog(@"Location dictionary is: %@",locationInfo);
        [imageMetadata setObject:locationInfo forKey:(NSString*)kCGImagePropertyGPSDictionary];
    }
    // Get the assets library
    ALAssetsLibraryWriteImageCompletionBlock imageWriteCompletionBlock =
    ^(NSURL *newURL, NSError *error) {
        if (error) {
            NSLog( @"Error writing image with metadata to Photo Library: %@", error );
        } else {
            NSLog( @"Wrote image %@ with metadata %@ to Photo Library",newURL,imageMetadata);
        }
    };
    // Save the new image to the Camera Roll
    [library writeImageToSavedPhotosAlbum:[imageToSave CGImage]
                                 metadata:imageMetadata
                          completionBlock:imageWriteCompletionBlock];
    //[imageMetadata release];
    //[library release];
}



- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissModalViewControllerAnimated:NO];
}

//read all the thumbnaisl of the passwe album
- (void)readAlbumThumbnails {
    
    
    [self.albums removeAllObjects];
    //do the assets enumeration
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset){
        
        //ALAssetRepresentation *rep = [myasset defaultRepresentation];
        CGImageRef thumbnailRef = [myasset thumbnail ];//fullResolutionImage
        
        if (thumbnailRef!=nil){
            
            //we have a thumbnail
            __block UIImage *thumbnailImage = [UIImage imageWithCGImage:thumbnailRef];
            
            BHAlbum *albumSingle = [[BHAlbum alloc] init];
            albumSingle.photosURLs = [[NSMutableArray alloc] init];
            albumSingle.name = [NSString stringWithFormat:@"%d",self.albums.count ];
            //save the URL of the asset Photo
            
            [self.albums addObject:albumSingle];
            //__block NSURL *url = [myasset valueForProperty:ALAssetPropertyAssetURL];
            //NSLog(@"Adding url : %@ on album with index: %d",url,self.albums.count);
            [albumSingle.photosURLs addObject: [myasset valueForProperty:ALAssetPropertyAssetURL]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                BHPhoto *photo = [BHPhoto photoWithImageData: thumbnailImage];
                [albumSingle addPhoto:photo];
                [self.collectionView reloadData];
                
            });
  
        }
        
        
    };
    
    ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror){
        NSLog(@"Failed to get image!");
        //failed to get image.
    };
    
    ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
    
    //BHAlbum *selected = [self.albums objectAtIndex:0];
    for(int i=0; i < selectedAlbum.photosURLs.count; i++) {
       //NSLog(@"Checking %@ which is %d of %d",[selectedAlbum.photosURLs objectAtIndex:i],i,selectedAlbum.photosURLs.count);
       [assetslibrary assetForURL:[selectedAlbum.photosURLs objectAtIndex:i] resultBlock:resultblock failureBlock:failureblock];
       
    }
    
    [self.collectionView reloadData];
    
    
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    //NSLog(@"Returning numberOfSectionsInCollectionView %d", album.photosURLs.count);
    //BHAlbum *selected = [self.albums objectAtIndex:0];
    NSLog(@"SIZE IS: %d",selectedAlbum.photosURLs.count);
    return selectedAlbum.photosURLs.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
   
    return 1; 
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
        BHAlbum *albumSelected =self.albums[row];
        //NSLog(@"entering code %d %d", photoIndex,albumSelected.photos.count);
        
        NSInteger tag = row;
        
        if(albumSelected.photos!=nil && albumSelected.photos.count > photoIndex) {
            BHPhoto *photo = albumSelected.photos[photoIndex];//which should only be 1indexPath.item
            
            // load photo images in the background
            __weak BHCollectionViewController *weakSelf = self;
            NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
                
                //UIImage *image = [UIImage imageWithCGImage:[photo.rawImage fullScreenImage]];
                //UIImage *image = [photo image];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    // then set them via the main queue if the cell is still visible.
                    if ([weakSelf.collectionView.indexPathsForVisibleItems containsObject:indexPath]) {
                        BHAlbumPhotoCell *cell =
                        (BHAlbumPhotoCell *)[weakSelf.collectionView cellForItemAtIndexPath:indexPath];
                        //NSLog(@"adding it here2");
                        
                        cell.imageView.image = photo.image;
                        cell.imageView.userInteractionEnabled = YES;
                        cell.imageView.tag = tag;
                        UITapGestureRecognizer *tapGesture =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapImageWithGesture:)];
                         [cell.imageView addGestureRecognizer:tapGesture];
                    }
                });
            }];
            
            operation.queuePriority = (indexPath.item == 0) ?
            NSOperationQueuePriorityHigh : NSOperationQueuePriorityNormal;
            
            [self.thumbnailQueue addOperation:operation];
        }
        else {
            //NSLog(@"NILZING!");
            //photoCell.imageView.image =nil;
        }
        
        
    }
    
    
    
    return photoCell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath;
{
    //NSLog(@"WHAT ABOUT HERE? indexpath: %d albumPhotos count:%d",indexPath.section,albumPhotos.count);
    
    
    BHAlbumTitleReusableView *titleView =
    [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                       withReuseIdentifier:AlbumTitleIdentifier
                                              forIndexPath:indexPath];
    NSInteger row = indexPath.section;
    if(self.albums.count >0 && row < self.albums.count) {
        BHAlbum *albumSelected = self.albums[indexPath.section];
        titleView.titleLabel.text = albumSelected.name;
    }
    else {
        titleView.titleLabel.text = [NSString stringWithFormat:@"%d",row];
    }
    
    return titleView;
}


//the user tapped on the image
- (void)didTapImageWithGesture:(UITapGestureRecognizer *)tapGesture{
    NSLog(@"image was clicked");
    
    
    
    UIImageView *imageView = (UIImageView*)tapGesture.view;
    NSInteger tag = imageView.tag;
    
    NSLog(@"selected image/album is %d",tag);
    
    
    if(tag < self.albums.count) {
        
       
        BHAlbum *albumTap= [self.albums objectAtIndex:tag];
        
        detailViewController.title = albumTap.name;
        NSURL *assetURL = [albumTap.photosURLs objectAtIndex:0];
        NSLog(@"The url here is : %@",assetURL);
        detailViewController.assetURL = [albumTap.photosURLs objectAtIndex:0];
        NSLog(@"pushing now: with assetURL %@",detailViewController.assetURL);
        [self.navigationController pushViewController:detailViewController animated:NO];
        
        
        //NSString *url =@"";
        //[self showDetailView:[albumTap.photosURLs objectAtIndex:0]];
        
    }
    
        /*
        //valid index
        // Create the item to share (in this example, a url)
               
         NSURL *url = [NSURL URLWithString:@"http://getsharekit.com"];
         SHKItem *item = [SHKItem URL:url title:@"ShareKit //is Awesome!"];
         
         // Get the ShareKit action sheet
         SHKActionSheet *actionSheet = [SHKActionSheet actionSheetForItem:item];
         
         // Display the action sheet
         [actionSheet showInView:imageView];
        
    }*/
      
    
}

//NSDictionary *metadata = asset.defaultRepresentation.metadata;
- (NSDictionary *)getGPSDictionaryForLocation:(CLLocation *)location {
    NSMutableDictionary *gps = [NSMutableDictionary dictionary];
    
    // GPS tag version
    [gps setObject:@"2.2.0.0" forKey:(NSString *)kCGImagePropertyGPSVersion];
    
    // Time and date must be provided as strings, not as an NSDate object
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm:ss.SSSSSS"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [gps setObject:[formatter stringFromDate:location.timestamp] forKey:(NSString *)kCGImagePropertyGPSTimeStamp];
    [formatter setDateFormat:@"yyyy:MM:dd"];
    [gps setObject:[formatter stringFromDate:location.timestamp] forKey:(NSString *)kCGImagePropertyGPSDateStamp];
    //[formatter release];
    
    // Latitude
    CGFloat latitude = location.coordinate.latitude;
    if (latitude < 0) {
        latitude = -latitude;
        [gps setObject:@"S" forKey:(NSString *)kCGImagePropertyGPSLatitudeRef];
    } else {
        [gps setObject:@"N" forKey:(NSString *)kCGImagePropertyGPSLatitudeRef];
    }
    [gps setObject:[NSNumber numberWithFloat:latitude] forKey:(NSString *)kCGImagePropertyGPSLatitude];
    
    // Longitude
    CGFloat longitude = location.coordinate.longitude;
    if (longitude < 0) {
        longitude = -longitude;
        [gps setObject:@"W" forKey:(NSString *)kCGImagePropertyGPSLongitudeRef];
    } else {
        [gps setObject:@"E" forKey:(NSString *)kCGImagePropertyGPSLongitudeRef];
    }
    [gps setObject:[NSNumber numberWithFloat:longitude] forKey:(NSString *)kCGImagePropertyGPSLongitude];
    
    // Altitude
    CGFloat altitude = location.altitude;
    if (!isnan(altitude)){
        if (altitude < 0) {
            altitude = -altitude;
            [gps setObject:@"1" forKey:(NSString *)kCGImagePropertyGPSAltitudeRef];
        } else {
            [gps setObject:@"0" forKey:(NSString *)kCGImagePropertyGPSAltitudeRef];
        }
        [gps setObject:[NSNumber numberWithFloat:altitude] forKey:(NSString *)kCGImagePropertyGPSAltitude];
    }
    
    // Speed, must be converted from m/s to km/h
    if (location.speed >= 0){
        [gps setObject:@"K" forKey:(NSString *)kCGImagePropertyGPSSpeedRef];
        [gps setObject:[NSNumber numberWithFloat:location.speed*3.6] forKey:(NSString *)kCGImagePropertyGPSSpeed];
    }
    
    // Heading
    if (location.course >= 0){
        [gps setObject:@"T" forKey:(NSString *)kCGImagePropertyGPSTrackRef];
        [gps setObject:[NSNumber numberWithFloat:location.course] forKey:(NSString *)kCGImagePropertyGPSTrack];
    }
    
    return gps;
}


@end
