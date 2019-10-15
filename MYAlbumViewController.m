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

#define ACTION_DELETE_ALBUM 3
#define ACTION_TAKE_PHOTO 4
#define ACTION_ADD_LOCATION 5
#define ACTION_ADD_TO_ALBUM 6

@interface MYAlbumViewController ()

@end



@implementation MYAlbumViewController


@synthesize detailViewController;
@synthesize listAlbumsAvailableController;
@synthesize albumsNames;
@synthesize selectedAlbumIndex;
@synthesize selectedAlbum,selectedPhoto,selectedAction,selectedItems;

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
    selectedItems = 0;
	// Do any additional setup after loading the view.
    
}

-(void) viewWillAppear:(BOOL)animated {
    
    self.selectedAction = 0;
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
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Album actions"
                                                                       message:@"Select one option:"
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
        
        
        UIAlertAction *editAlbumAction = [UIAlertAction actionWithTitle:@"Edit album location" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // this block runs when the driving option is selected
            self.selectedAction = ACTION_ADD_LOCATION;
            [self addLocation:nil];
        }];
        UIAlertAction *takePhotoAction = [UIAlertAction actionWithTitle:@"Take photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // this block runs when the walking option is selected
            self.selectedAction = ACTION_ADD_LOCATION;
            [self takePhoto:nil];
        }];
        UIAlertAction *deleteAlbumAction = [UIAlertAction actionWithTitle:@"Delete album" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.selectedAction = ACTION_DELETE_ALBUM;
            [self deleteAlbum:nil];
        }];
        
        UIAlertAction *addPhotosAction = [UIAlertAction actionWithTitle:@"Add photos to album" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.selectedAction = ACTION_ADD_TO_ALBUM;
            [self addPhotosToCurrentAlbum:nil];
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        
        [alert addAction:editAlbumAction];
        [alert addAction:takePhotoAction];
        [alert addAction:deleteAlbumAction];
        [alert addAction:addPhotosAction];
        [alert addAction:cancelAction];
        
        alert.popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItem;
        [self presentViewController:alert animated:YES completion:nil];
        
        /*AlbumOptionsTableViewController *optionsController = [[AlbumOptionsTableViewController alloc] initWithNibName:@"AlbumOptionsTableViewController" bundle:nil controller:self];
        [self.navigationController pushViewController:optionsController animated:YES];*/
    }
    else if(tag == SELECT_ALL_TAG) {
        [self selectAllAlbumThumbnails: true];
        self.navigationItem.rightBarButtonItem.tag = UNSELECT_ALL_TAG;
        self.navigationItem.rightBarButtonItem.title = @"UnSelect All";
    }
    else if(tag == ACTION_ADD_TO_ALBUM && selectedPhoto!=nil && selectedItems>0) {
        [self addPhotosToCurrentAlbum:nil];
        [self selectAllAlbumThumbnails:false];
    }
    else {
        //unselect all
        [self selectAllAlbumThumbnails: false];
        self.navigationItem.rightBarButtonItem.tag = ACTIONS_TAG;
        self.navigationItem.rightBarButtonItem.title = @"Actions";
    }
    
  
}

-(IBAction)addPhotosToCurrentAlbum:(id)sender {
    //TODO actual theyr are already in this album, so need to ask for other or create a new one!!!
    NSLog(@"start selecting photos");
    //TODO disable the button or change it´s label to select
    //add another one to select all
    self.navigationItem.rightBarButtonItem.tag = SELECT_ALL_TAG;
    self.navigationItem.rightBarButtonItem.title = @"Select All";
}
/*
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

*/

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
    
    NSInteger __block processed = 0;
    NSInteger count = selectedAlbum.photosURLs.count;
    [self.albums removeAllObjects];
    
    dispatch_async(dispatch_get_main_queue(), ^{
      [self.collectionView.collectionViewLayout invalidateLayout];
      [self.collectionView reloadData];
    });
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
            
            processed++;
            

                BHPhoto *photo = [BHPhoto photoWithImageData: thumbnailImage];
                [albumSingle addPhoto:photo];
                NSLog(@"PROCESSED %ld", (long)processed);
                if(processed == count) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                            [self.collectionView.collectionViewLayout invalidateLayout];
                            [self.collectionView reloadData];
                        
                        });
                }
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
    
    
    
    
}

- (void)selectAllAlbumThumbnails: (BOOL) select {
    
    //set them as selected
    for(BHAlbum *album in self.albums) {
        BHPhoto *photo = [album.photos objectAtIndex:0];
        photo.isSelected = select;
    }
    selectedItems = select ? self.albums.count : 0;
    
    //make the table refresh
    [self.collectionView.collectionViewLayout invalidateLayout];
    [self.collectionView reloadData];
    
    
}

-(void)selectAlbumPhoto: (BOOL) select atIndex:(NSInteger) index {

    if(index < self.albums.count) {
        
        self.selectedPhoto  = [self.albums objectAtIndex:index];
        
        if(select) {
            
            BHPhoto *photo = [self.selectedPhoto.photos objectAtIndex:0];
            photo.isSelected = select;
            //TODO the button should not be called select all anymore
            self.selectedAction = ACTION_ADD_TO_ALBUM;
            self.navigationItem.rightBarButtonItem.tag = ACTION_ADD_TO_ALBUM;
            self.navigationItem.rightBarButtonItem.title = @"Add to album";
            selectedItems+=1;
        }
        else {
            BHPhoto *photo = [self.selectedPhoto.photos objectAtIndex:0];
            photo.isSelected = select;
            self.selectedPhoto = nil;
            selectedItems-=1;
            if(selectedItems < 0) {
               selectedItems = 0;
            }
        }
        
        //make the table refresh
        [self.collectionView.collectionViewLayout invalidateLayout];
        [self.collectionView reloadData];
    }
    
}


#pragma mark - UICollectionViewDataSource


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    NSLog(@"NUM photos in album is %lu",(unsigned long)selectedAlbum.photosURLs.count);
    return selectedAlbum.photosURLs.count > 0 ? selectedAlbum.photosURLs.count : 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    //number of images on top of the others/paging ilussion, should be always 1
    if(selectedAlbum.photosURLs.count > 0) {
       return 1;
    }
    return 0;
}

//TODO i just changed the animation on the push, and the title, don´t know why i got the ghost albums at 1st run..
//I SHOULD JUST MOVE TO NEXT PAGE(details) ON DOUBLE TAP (or button labeled GO)
//OTHERWISE IT SHOULD JUST SELECT

//TODO implement this instead of the tap gesture

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    BHAlbumPhotoCell *photoCell =
    [collectionView dequeueReusableCellWithReuseIdentifier:PhotoCellIdentifier
                                              forIndexPath:indexPath];
    
    NSInteger row = indexPath.section;
    NSInteger photoIndex = indexPath.item;
    
    if(row < self.albums.count) {
        self.selectedPhoto = self.albums[row];
    }
    [photoCell setPhotoSelected:true];
    
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
            
            photoCell.imageView.image = photo.image;
            photoCell.imageView.userInteractionEnabled = YES;
            [photoCell setPhotoSelected:isSelected];
            //TODO do i need to have this alos on the main thread?? probably just update the image no???
            photoCell.imageView.tag = tag;
            UITapGestureRecognizer *tapGesture =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapImageWithGesture:)];
            [photoCell.imageView addGestureRecognizer:tapGesture];
         
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
    /*if(self.albums.count >0 && row < self.albums.count) {
        BHAlbum *albumSelected = self.albums[indexPath.section];
        titleView.titleLabel.text = albumSelected.name;
    }
    else {*/
        titleView.titleLabel.text = [NSString stringWithFormat:@"%ld",(long)row];
    //}
    
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
    
    UIImageView *imageView = (UIImageView*)tapGesture.view;
    NSInteger tag = imageView.tag;
    
    NSLog(@"selected image/album is %ld",(long)tag);
    
    
    if(tag < self.albums.count) {
       
        //represents here an album with just one image
        BHAlbum *albumTap = [self.albums objectAtIndex:tag];
        BHPhoto *photo = [albumTap.photos objectAtIndex:0];
        
        //nothing selected yet, select it now
        if(self.selectedAction==ACTION_ADD_TO_ALBUM) {
            
            
            if(!photo.isSelected) {
                
                [self selectAlbumPhoto:YES atIndex:tag];
                NSLog(@"select now at position %ld",(long)tag);
            }
            else {
                [self selectAlbumPhoto:NO atIndex:tag];
                NSLog(@"Unselect now at position %ld",(long)tag);
            }
            

        }
        else {
            //JUST SHOW DETAIL
            detailViewController.title = albumTap.name;
            NSURL *assetURL = [albumTap.photosURLs objectAtIndex:0];
            NSLog(@"The url here is : %@",assetURL);
            detailViewController.enclosingAlbum = selectedAlbum;
            //the albumTap has just one image
            detailViewController.assetURL = [albumTap.photosURLs objectAtIndex:0];
            NSLog(@"pushing now: with assetURL %@",detailViewController.assetURL);
            [self.navigationController pushViewController:detailViewController animated:NO];
        }
        
    }
    
      
    
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
