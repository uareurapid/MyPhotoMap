//
//  PhotoDetailViewController.m
//  CollectionViewTutorial
//
//  Created by Paulo Cristo on 6/6/13.
//  Copyright (c) 2013 Bryan Hansen. All rights reserved.
//

#import "PhotoDetailViewController.h"
#import <Photos/PHPhotoLibrary.h>
#import <Photos/PHAssetCollectionChangeRequest.h>
#import <Photos/Photos.h>

@interface PhotoDetailViewController ()

@end

@implementation PhotoDetailViewController

@synthesize assetURL,thumbnail,enclosingAlbum,selectedIndex,locationEntitiesArray,dataModel,photoCellView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self.navigationItem setHidesBackButton:NO];
        
        
        /*UIBarButtonItem *editTitle = [[UIBarButtonItem alloc] initWithTitle:@"Edit Title"
                                                                         style:UIBarButtonItemStyleDone target:self action:@selector(addLabelClicked:)];*/
        
        //*************************************************************
        //O botao so aparece se a imagem seleccionada (ou o assetURL) não estiver nabd
        //ou theno uma flag, para alterar a localização
        UIBarButtonItem *editSettings = [[UIBarButtonItem alloc] initWithTitle:@"Edit..."
                                                                        style:UIBarButtonItemStyleDone target:self action:@selector(editSettings:)];
        
        
        self.navigationItem.rightBarButtonItem = editSettings;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    selectedIndex = 0;
    //[photoView setUserInteractionEnabled:YES];
    
    CGRect rect = CGRectMake(self.view.bounds.origin.x+20, self.view.bounds.origin.y+40, self.view.bounds.size.width-40, self.view.bounds.size.height-120);
    photoCellView = [[BHPhotoAlbumView alloc ] initWithFrame: rect];
    photoCellView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    photoCellView.imageView.userInteractionEnabled = YES;
    
    //initWithFrame:CGRectMake(-10, 70, 320, 480)];
    
    [self.view addSubview:photoCellView];
    
    [self.view bringSubviewToFront:photoCellView];
    
    //UITapGestureRecognizer *tapGesture =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapImageThumbnailWithGesture:)];
    //[photoCellView.imageView addGestureRecognizer:tapGesture];
    
    // Do any additional setup after loading the view from its nib.
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    
    // Setting the swipe direction.
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    
    [photoCellView.imageView addGestureRecognizer:swipeLeft];
    [photoCellView.imageView addGestureRecognizer:swipeRight];
    
    // Adding the swipe gesture on image view
    //[photoView addGestureRecognizer:swipeLeft];
    //[photoView addGestureRecognizer:swipeRight];
    
    locationEntitiesArray = [[NSMutableArray alloc] init];
    
    [self updateTitle];
}

- (void)didTapImageThumbnailWithGesture:(UITapGestureRecognizer *)tapGesture{
    NSLog(@"image was clicked");
}

- (void)handleSwipe:(UISwipeGestureRecognizer *)swipe {
    
    NSInteger albumSize = enclosingAlbum.photosURLs.count;
    //enclosingAlbum.photosURLs objectAtIndex:0];
    if (swipe.direction == UISwipeGestureRecognizerDirectionLeft) {
        NSLog(@"Left Swipe");
        if(selectedIndex > 0 && albumSize > 0) {
            selectedIndex--;
            if(selectedIndex < 0) {
                selectedIndex = albumSize-1;
            }
        }
        else {
            selectedIndex = albumSize-1;
        }
        
    }
    
    if (swipe.direction == UISwipeGestureRecognizerDirectionRight) {
        NSLog(@"Right Swipe");
        if(selectedIndex < (albumSize-1) ) {
            selectedIndex++;
        }
        else {
            selectedIndex = 0;
        }
    }
    
    NSLog(@"selected index %ld and size is %ld",(long)selectedIndex,(long)albumSize);
    
    //Curl Animation!!!
    assetURL = [enclosingAlbum.photosURLs objectAtIndex:selectedIndex];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:photoCellView.imageView cache:YES];
    [UIView setAnimationDuration:1.5];
    /// ----> [YourView CodeTo Be Done];
    [UIView commitAnimations];
    
    [self readFullSizeImageAndThumbnail];
    
    
}


-(void) updateTitle {
    
    if(self.assetURL!=nil) {
        self.dataModel = [self fetchLocationModelWithAssetURL:self.assetURL ];
        if(self.dataModel!=nil && self.dataModel.desc!=nil){
            self.title = self.dataModel.desc;
        }
    }
}

-(void) viewWillAppear:(BOOL)animated {
    selectedIndex =0;
    //NSLog(@" i have %d url: %@",self.navigationItem.leftBarButtonItems.count,assetURL);
    [self readFullSizeImageAndThumbnail];
    [self updateTitle];
}

-(void) viewWillDisappear:(BOOL)animated{
    if( [self isBeingDismissed]) {
      //TODO do not reload teh previous one
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:true forKey:@"was_dismissed"];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)closeWindow:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

//edit photo location
-(IBAction)editSettings:(id)sender {
    
    //instead show an alert view with actions
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Edit photo"
                                                                   message:@"Where was the photo taken? What´s represented?"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Edit Location" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                          
                                                              [self openLocationView];
                                                          }];
    
    UIAlertAction* editTitleAction = [UIAlertAction actionWithTitle:@"Edit Title" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                          
                                                              [self changeLabel];
                                                          }];
    
    [alert addAction:defaultAction];
    [alert addAction:editTitleAction];
    [self presentViewController:alert animated:YES completion:nil];
    
}


-(void) openLocationView{
    SearchLocationViewController *view = [(PCAppDelegate *)[[UIApplication sharedApplication] delegate] searchController];
    view.assetURL = assetURL; //set the asset url
    view.image = thumbnail;
    [self.navigationController pushViewController:view animated:YES];
}


#pragma add title description

- (void)changeLabel{
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"New label..." message:@"Enter the photo label" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save",nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *textField = [alert textFieldAtIndex:0];
    textField.text = self.title;
    [alert show];
}

//the delegate for the new Album
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(buttonIndex==1) { //0 - cancel, 1 - save
        NSString *label = [alertView textFieldAtIndex:0].text;
        //check if this label already exists in some model (must have same url)
        [self fetchLocationRecords:label];
    }
    
}

//gte this photo/album location model
- (LocationDataModel *)fetchLocationModelWithAssetURL: (NSString *) assetURL {
    
    NSMutableArray *mutableFetchResults = [CoreDataUtils fetchLocationRecordsFromDatabaseWithAssetURL: assetURL];
    if (!mutableFetchResults) {
        //ERROR
        return nil;
    }
    else if(mutableFetchResults.count==1) {
        //OK
        return [mutableFetchResults objectAtIndex:0];
    }
    return nil;
}

#pragma save locations core data
//fetch all the records from the database
- (void)fetchLocationRecords: (NSString *) descriptionString {
    
    //do nothing if it doesn´t exist
    if(self.dataModel==nil) {
        NSLog(@"don´t found any model");
        //TODO create one now
        return;
    }
    
    BOOL canUpdate = false;
    //TODO, improve method to include assetURL in the query predicate as well
    NSMutableArray *mutableFetchResults = [CoreDataUtils fetchLocationRecordsFromDatabaseWithDescription: descriptionString];
    if (!mutableFetchResults) {
        //ERROR
        return;
    }
    else if(mutableFetchResults.count==0) {
     //OK
        canUpdate = true;
    }
    else {
        //TODO alert because the label already exists
        BOOL found = false;
        LocationDataModel *locationObject = nil;
        for(LocationDataModel *entity in mutableFetchResults) {
            //load the thumbnail
            if(entity.assetURL!=nil && [entity.assetURL isEqualToString: self.assetURL]) {
                //found it
                found = true;
                locationObject = entity;
                break;
            }
        }
        if(!found) {
            canUpdate = true;
            //OK
        
        }
        else {
            //NOK, already exists
        }
    }
    
    if(canUpdate) {
        NSManagedObjectContext *managedObjectContext = [(PCAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        
        //update the description and save the context/model
        dataModel.desc= descriptionString;
        NSError *error;
        if (![managedObjectContext save:&error]) {
            NSLog(@"Whoops, unable to save");
        }
        else{
            //save ok
            self.title = self.dataModel.desc;
        }  
    }
    
    
    
    // Save our fetched data to an array
    //[self setLocationEntitiesArray: mutableFetchResults];
    
    //if(image!=nil && OK==YES) {
    //NSLog(@"Adding to the map....");
    //[mapView addLocation:location.clLocation withImage:image andTitle:@"Another teste"];
}

- (void)readFullSizeImageAndThumbnail {
    
    
    PHImageManager *imageManager = [PHImageManager defaultManager];
    PHFetchOptions *options = [PHFetchOptions new];
    options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
    NSLog(@"will try load asset thumnail %@", assetURL);
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsWithLocalIdentifiers:[[NSMutableArray alloc] initWithObjects: assetURL,nil] options:options];
    if(assets!=nil && assets.count >0) {
        
        PHAsset *asset = [assets firstObject];
        if(asset!=nil){
               PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
               requestOptions.resizeMode   = PHImageRequestOptionsResizeModeExact;
               requestOptions.networkAccessAllowed = true;
               requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
               requestOptions.synchronous = true;
               
               NSLog(@"THE DETAIL URL IS %@", self.assetURL);
               [imageManager requestImageForAsset:asset
                                      targetSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)//CGSizeMake(125.0f, 125.0f)//CGSizeMake(self.photoCellView.imageView.frame.size.width, self.photoCellView.imageView.frame.size.height)
                                     contentMode:PHImageContentModeDefault
                                         options:requestOptions
                                   resultHandler:^void(UIImage *image, NSDictionary *info) {
                                       if(image!=nil) {
                                           //alwyas update the UI in the main thread
                                           NSLog(@"OK, got the image");
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               self.photoCellView.imageView.image = image;
                                            
                                           });
                                       } else {
                                           NSLog(@"NIL image");
                                       }
               }];
        }
   }
    
    
}

//[UIImage imageWithCGImage:[asset defaultRepresentation].fullScreenImage scale:1.0 orientation:(UIImageOrientation)[asset defaultRepresentation].orientation];
+(NSMutableDictionary *)updateExif:(CLLocation *)currentLocation{
    
    
    NSMutableDictionary* locDict = [[NSMutableDictionary alloc] init];
    
    
    CLLocationDegrees exifLatitude = currentLocation.coordinate.latitude;
    CLLocationDegrees exifLongitude = currentLocation.coordinate.longitude;
    
    [locDict setObject:currentLocation.timestamp forKey:(NSString*)kCGImagePropertyGPSTimeStamp];
    
    if (exifLatitude <0.0){
        exifLatitude = exifLatitude*(-1);
        [locDict setObject:@"S" forKey:(NSString*)kCGImagePropertyGPSLatitudeRef];
    }else{
        [locDict setObject:@"N" forKey:(NSString*)kCGImagePropertyGPSLatitudeRef];
    }
    [locDict setObject:[NSNumber numberWithFloat:exifLatitude] forKey:(NSString*)kCGImagePropertyGPSLatitude];
    
    if (exifLongitude <0.0){
        exifLongitude=exifLongitude*(-1);
        [locDict setObject:@"W" forKey:(NSString*)kCGImagePropertyGPSLongitudeRef];
    }else{
        [locDict setObject:@"E" forKey:(NSString*)kCGImagePropertyGPSLongitudeRef];
    }
    [locDict setObject:[NSNumber numberWithFloat:exifLongitude] forKey:(NSString*) kCGImagePropertyGPSLongitude];
    
    
    return locDict;
    
}
/*
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [imageMetaData setDictionary:[[info objectForKey:UIImagePickerControllerMediaMetadata] copy]];
}

[imageMetaData setObject:currentLocation forKey:(NSString*)kCGImagePropertyGPSDictionary];
//[library writeImageToSavedPhotosAlbum:[viewImage CGImage] metadata:imageMetaData completionBlock:photoCompblock];
 assets lib call
 - (void)writeImageDataToSavedPhotosAlbum:(NSData *)imageData
 metadata:(NSDictionary *)metadata
 completionBlock:(ALAssetsLibraryWriteImageCompletionBlock)completionBlock
 */
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

//Assign the dictionary returned by this method as the value for the kCGImagePropertyGPSDictionary key in the metadata dictionary you pass to writeImageDataToSavedPhotosAlbum:metadata:completionBlock: or CGImageDestinationAddImage().
/**
 
 LOCATION FORMAT ON SAVED METADATA
 location is <+39.73916667,-8.82350000> +/- 0.00m (speed -1.00 mps / course -1.00) @ 6/12/13, 10:47:03 Western European Summer Time
 2013-06-12 10:47:03.633 CollectionViewTutorial[2262:907] metadata is {
 ColorModel = RGB;
 DPIHeight = 72;
 DPIWidth = 72;
 Depth = 8;
 Orientation = 1;
 PixelHeight = 1936;
 PixelWidth = 2592;
 "{Exif}" =     {
 ColorSpace = 1;
 ComponentsConfiguration =         (
 1,
 2,
 3,
 0
 );
 ExifVersion =         (
 2,
 2,
 1
 );
 FlashPixVersion =         (
 1,
 0
 );
 PixelXDimension = 2592;
 PixelYDimension = 1936;
 SceneCaptureType = 0;
 };
 "{GPS}" =     {
 Altitude = "47.18736";
 DateStamp = "2013:06:12";
 Latitude = "39.73916666666667";
 LatitudeRef = N;
 Longitude = "8.823499999999999";
 LongitudeRef = W;
 TimeStamp = "09:38:24.10";
 };
 "{TIFF}" =     {
 Orientation = 1;
 ResolutionUnit = 2;
 XResolution = 72;
 YResolution = 72;
 "_YCbCrPositioning" = 1;
 };
 }
 */
@end
