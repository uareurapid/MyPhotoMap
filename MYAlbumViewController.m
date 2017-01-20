//
//  MYAlbumViewController.m
//  CollectionViewTutorial
//
//  Created by Paulo Cristo on 6/6/13.
//  Copyright (c) 2013 Bryan Hansen. All rights reserved.
//

#import "MYAlbumViewController.h"

#import "AlbumOptionsTableViewController.h"
#import "PCAppDelegate.h"

#define ACTIONS_TAG 0
#define SELECT_ALL_TAG 1
#define UNSELECT_ALL_TAG 2

@interface MYAlbumViewController ()

@end



@implementation MYAlbumViewController


@synthesize detailViewController;
@synthesize listAlbumsAvailableController;
@synthesize albumsNames;
@synthesize selectedAlbumIndex;
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
        addAlbumButton.tag = ACTIONS_TAG;//to know the function of the button
        self.navigationItem.rightBarButtonItem = addAlbumButton;
        albumsNames = [[NSMutableArray alloc] init];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
}

-(void) viewWillAppear:(BOOL)animated {
    [self readAlbumThumbnails];
}

//add the "real" existing albums" names
-(void) addAlbumsNamesFromArray: (NSMutableArray*) names {
    [albumsNames removeAllObjects];
    [albumsNames addObjectsFromArray:names];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)settingsClicked:(id) sender{
    
    NSInteger tag = self.navigationItem.rightBarButtonItem.tag;
    if(tag == ACTIONS_TAG) {
        //will show a lit with two options
        //edit location and take photo
        AlbumOptionsTableViewController *optionsController = [[AlbumOptionsTableViewController alloc] initWithNibName:@"AlbumOptionsTableViewController" bundle:nil controller:self];
        [self.navigationController pushViewController:optionsController animated:YES];
    }
    else if(tag == SELECT_ALL_TAG) {
        [self selectAllAlbumThumbnails: true];
        self.navigationItem.rightBarButtonItem.tag = UNSELECT_ALL_TAG;
        self.navigationItem.rightBarButtonItem.title = @"UnSelect All";
    }
    else {
        //unselect all
        [self selectAllAlbumThumbnails: false];
        self.navigationItem.rightBarButtonItem.tag = ACTIONS_TAG;
        self.navigationItem.rightBarButtonItem.title = @"Actions";
    }
    
  
}

-(IBAction)addPhotosToCurrentAlbum:(id)sender {
    NSLog(@"start selecting photos");
    //TODO disable the button or change it´s label to select
    //add another one to select all
    self.navigationItem.rightBarButtonItem.tag = SELECT_ALL_TAG;
    self.navigationItem.rightBarButtonItem.title = @"Select All";
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
    
    SearchLocationViewController *view = [(PCAppDelegate *)[[UIApplication sharedApplication] delegate] searchController];
    
    view.navigationItem.rightBarButtonItem = nil;
    view.navigationItem.leftBarButtonItem = nil;
    
    NSLog(@"selected album index: %lu",(unsigned long)selectedAlbumIndex);
    
    //OK I HAVE THE SELECTED ALBUM
    BHAlbum *theSelectedAlbum = [self.albums objectAtIndex:selectedAlbumIndex];
    view.selectedAlbum = theSelectedAlbum;
    view.assetURL = theSelectedAlbum.assetURL; //set the asset url (nil if a yealy album)
    theSelectedAlbum.photosURLs = [[NSMutableArray alloc] initWithCapacity:selectedAlbum.photosCount];
    [theSelectedAlbum.photosURLs addObjectsFromArray:[selectedAlbum photosURLs]];
    
    //this has the ciorrect value: selectedAlbum.photosURLs.count
    
    //assign the correct photo
    if(theSelectedAlbum.photosURLs.count>0) {
        //TODO this photos is not being added 
        BHPhoto *photo = [theSelectedAlbum.photos objectAtIndex:0];
        view.image = photo.image;
        //we save the thumbnail URL on the LocationDataModel
        view.thumbnailURL = photo.imageURL;
    }
    else {
        view.image = [UIImage imageNamed:@"concrete"];
        view.thumbnailURL = nil;
    }
    
    view.mapView = [(PCAppDelegate *)[[UIApplication sharedApplication] delegate] mapViewController];
    
    
    [self.navigationController pushViewController:view animated:NO];
}

- (IBAction)deleteAlbum:(id)sender {
    
    if(selectedAlbum!=nil) {
        NSLog(@"DELETE ALBUM %@",selectedAlbum.name);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"You can only delete the album from the photos app"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [self.navigationController popToRootViewControllerAnimated:TRUE];
    }
}


#pragma mark Image picker delegate methdos
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo

{
    
    [picker dismissViewControllerAnimated:NO
                               completion: ^{[self showAlbumsList: image editingInfo:editingInfo];}];
}

- (void) showAlbumsList:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    
    
    
    NSMutableArray *albumsAvailable = [[NSMutableArray alloc]init];
    for(NSString *albumName in albumsNames) {
        [albumsAvailable addObject:albumName];
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
            
            //if the record exists on DB, try get the title name from the album/pic description
            NSString *theURL = [[myasset valueForProperty:ALAssetPropertyAssetURL] absoluteString];
            if(theURL!=nil) {
                NSMutableArray *records = [CoreDataUtils fetchLocationRecordsFromDatabaseWithAssetURL:theURL];
                if(records!=nil && records.count==1) {
                    LocationDataModel *model = [records objectAtIndex:0];
                    if(![model.desc isEqualToString:@"NA"]) {
                        albumSingle.name = model.desc;
                    }
                    else {
                        //DEFAULT
                        albumSingle.name = [NSString stringWithFormat:@"%lu",(unsigned long)self.albums.count ];
                    }
                }
                
            }
            else {
                 //DEFAULT
                 albumSingle.name = [NSString stringWithFormat:@"%lu",(unsigned long)self.albums.count ];
            }
            
           
            //save the URL of the asset Photo
            
            [self.albums addObject:albumSingle];

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
    
    //pass each assetUrl at the time
    for(int i=0; i < selectedAlbum.photosURLs.count; i++) {
       [assetslibrary assetForURL:[selectedAlbum.photosURLs objectAtIndex:i] resultBlock:resultblock failureBlock:failureblock];
    }
    [self.collectionView.collectionViewLayout invalidateLayout];
    [self.collectionView reloadData];
    
    
}

- (void)selectAllAlbumThumbnails: (BOOL) select {
    
    //set them as selected
    for(BHAlbum *album in self.albums) {
        BHPhoto *photo = [album.photos objectAtIndex:0];
        photo.isSelected = select;
    }
    
    //make the table refresh
    [self.collectionView.collectionViewLayout invalidateLayout];
    [self.collectionView reloadData];
    
    
}


#pragma mark - UICollectionViewDataSource


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    NSLog(@"NUM photos in album is %lu",selectedAlbum.photosURLs.count);
    return selectedAlbum.photosURLs.count > 0 ? selectedAlbum.photosURLs.count : 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
   
    return 1; 
}

//TODO implement this instead of the tap gesture

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    BHAlbumPhotoCell *photoCell =
    [collectionView dequeueReusableCellWithReuseIdentifier:PhotoCellIdentifier
                                              forIndexPath:indexPath];
    [photoCell setPhotoSelected:true];
    
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(nonnull NSIndexPath *)indexPath{
    BHAlbumPhotoCell *photoCell =
    [collectionView dequeueReusableCellWithReuseIdentifier:PhotoCellIdentifier
                                              forIndexPath:indexPath];
    [photoCell setPhotoSelected:false];
    
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
        
        NSInteger tag = row;
        
        if(albumSelected.photos!=nil && albumSelected.photos.count > photoIndex) {
            BHPhoto *photo = albumSelected.photos[photoIndex];//which should only be 1indexPath.item
            BOOL isSelected = photo.isSelected;
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
                        [cell setPhotoSelected:isSelected];
                        //TODO do i need to have this alos on the main thread?? probably just update the image no???
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
        titleView.titleLabel.text = [NSString stringWithFormat:@"%ld",(long)row];
    }
    
    return titleView;
}

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


//the user tapped on the image
- (void)didTapImageWithGesture:(UITapGestureRecognizer *)tapGesture{
    NSLog(@"image was clicked");
    
    
    
    UIImageView *imageView = (UIImageView*)tapGesture.view;
    NSInteger tag = imageView.tag;
    
    NSLog(@"selected image/album is %ld",(long)tag);
    
    
    if(tag < self.albums.count) {
        
       
        //represents here an album with just one image
        BHAlbum *albumTap= [self.albums objectAtIndex:tag];
        
        detailViewController.title = albumTap.name;
        NSURL *assetURL = [albumTap.photosURLs objectAtIndex:0];
        NSLog(@"The url here is : %@",assetURL);
        detailViewController.enclosingAlbum = selectedAlbum;
        //the albumTap has just one image
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
