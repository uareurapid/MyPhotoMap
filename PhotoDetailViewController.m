//
//  PhotoDetailViewController.m
//  CollectionViewTutorial
//
//  Created by Paulo Cristo on 6/6/13.
//  Copyright (c) 2013 Bryan Hansen. All rights reserved.
//

#import "PhotoDetailViewController.h"


@interface PhotoDetailViewController ()

@end

@implementation PhotoDetailViewController

@synthesize photoView,assetURL,thumbnail;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self.navigationItem setHidesBackButton:NO];
        
        //*************************************************************
        //O botao so aparece se a imagem seleccionada (ou o assetURL) não estiver nabd
        //ou theno uma flag, para alterar a localização
        UIBarButtonItem *editLocation = [[UIBarButtonItem alloc] initWithTitle:@"Edit location"
                                                                        style:UIBarButtonItemStyleDone target:self action:@selector(editLocation:)];
        
        
        self.navigationItem.rightBarButtonItem = editLocation;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(void) viewWillAppear:(BOOL)animated {
    //NSLog(@" i have %d url: %@",self.navigationItem.leftBarButtonItems.count,assetURL);
    [self readFullSizeImageAndThumbnail];
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
-(IBAction)editLocation:(id)sender {
    SearchLocationViewController *view = [[SearchLocationViewController alloc] initWithNibName:@"SearchLocationViewController" bundle:nil];
    view.assetURL = assetURL; //set the asset url
    view.image = thumbnail;
    [self.navigationController pushViewController:view animated:YES];
}

- (void)readFullSizeImageAndThumbnail {
    
    //do the assets enumeration
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *asset){
        
    
        ALAssetRepresentation *rep = [asset defaultRepresentation];
        CGImageRef iref = [rep fullResolutionImage];
        CGImageRef thumb = [asset thumbnail];
        
        
        CLLocation *location = [asset valueForProperty:ALAssetPropertyLocation];
        NSLog(@"asset location is %@",location);
        NSLog(@"asset metadata is %@",rep.metadata);
        
        if(iref!=nil) {
            // scale:1.0 orientation:(UIImageOrientation)[asset defaultRepresentation].orientation]
            
            __block UIImage *image = [UIImage imageWithCGImage:iref];
            __block UIImage *imageThumb = [UIImage imageWithCGImage:thumb];
            
            thumbnail = imageThumb;
            
            //alwyas update the UI in the main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                
                photoView.image = image;
                
            });
        }
        
        
    };
    
    ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror){
        NSLog(@"Failed to get image!");
        //failed to get image.
    };
    
    ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
    [assetslibrary assetForURL:assetURL resultBlock:resultblock failureBlock:failureblock];

    
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
