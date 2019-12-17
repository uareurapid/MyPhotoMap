//
//  AlbumsListViewController.m
//  CollectionViewTutorial
//
//  Created by Paulo Cristo on 6/8/13.
//  Copyright (c) 2013 Bryan Hansen. All rights reserved.
//

#import "AlbumsListViewController.h"
#import <ImageIO/CGImageSource.h>
#import <ImageIO/CGImageProperties.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>
#import "iToast.h"
#import <Photos/PHPhotoLibrary.h>
#import <Photos/PHAssetCollectionChangeRequest.h>
#import <Photos/Photos.h>

@interface AlbumsListViewController ()

@end

@implementation AlbumsListViewController

@synthesize albumsNames;
@synthesize library;
@synthesize predefinedAlbum;
@synthesize imageInfo,imageToSave,photoLocation, albumController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        if(albumsNames==nil)
            albumsNames = [[NSArray alloc] init];
        
        library = [[ALAssetsLibrary alloc] init];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil predefined: (NSString*) albumName
{
    self = [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        predefinedAlbum = albumName;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil predefined: (NSString*) albumName available: (NSArray *)albums
{
    self = [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil predefined:albumName];
    if (self) {
        // Custom initialization
        albumsNames = [[NSArray alloc] initWithArray:albums copyItems:YES];
        
        UIBarButtonItem *fixedItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        fixedItem.width = self.view.frame.size.width - 120; // or whatever you want
        
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Save"
                                                                 style:UIBarButtonItemStyleDone target:self action:@selector(performSaveActions:)];
        [doneButton setBackgroundImage:[UIImage imageNamed:@"concrete"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
               
        NSArray *itemsArray = [NSArray arrayWithObjects:fixedItem, doneButton, nil];


        UIToolbar *myToolBar = [UIToolbar new];
        CGRect toolBarFrame = CGRectMake(0, 0, self.view.frame.size.width, 40);
        [myToolBar setFrame:toolBarFrame];
        [myToolBar setItems:itemsArray];
        [self.view addSubview:myToolBar];
        
        self.title = @"Available albums";
    }
    return self;
}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.allowsSelection = true;
    
    
    

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
  
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
      return albumsNames.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    if(row < albumsNames.count) {
        NSString *name = [albumsNames objectAtIndex:row];
        self.predefinedAlbum = name;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
 
    NSInteger row = indexPath.row;
    
    
        if(row < albumsNames.count) {
            NSString *name = [albumsNames objectAtIndex:row];
            cell.textLabel.text = name;
            cell.accessoryType = [name isEqualToString:self.predefinedAlbum] ?  UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            
        }
    
    return cell;
}


-(void) performSaveActions:(id) sender {   
        
        if(self.predefinedAlbum!=nil) {
       
            if(self.imageToSave!=nil) {
                NSLog(@"saving image to %@",self.predefinedAlbum);
                [self saveImageMetadata];
                [self saveOnAlbum:self.imageToSave];
            }
        }
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


//save on the album
- (void)saveOnAlbum: (UIImage*)image{
    
    [self saveImage:image toAlbum:predefinedAlbum withCompletionBlock:^(NSError *error) {
        
        if (error!=nil) {
            
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Unable to save photo or its data" message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
            [alert show];
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else {
            //add the asset to the custom photo album
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Successfully saved image!" message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
            [alert show];
            
            [self dismissViewControllerAnimated:YES completion:^{
                //reload assets/thumbnails and pop to view
                if(self.albumController!=nil) {
                   [self.albumController reloadAllAlbumInfo:self.predefinedAlbum];
                }
            }];
     
            
        }
    }];
}

//-(void) didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;{
 //UIImageWriteToSavedPhotosAlbum(image, self, @selector(didFinishSavingWithError:contextInfo:), nil);
//}

-(void)saveImage:(UIImage*)image toAlbum:(NSString*)albumName withCompletionBlock:(SaveImageCompletion)completionBlock
{
    
   
    
    
    //write the image data to the assets library (camera roll)
    [library writeImageToSavedPhotosAlbum:image.CGImage orientation:(ALAssetOrientation)image.imageOrientation
                          completionBlock:^(NSURL* assetURL, NSError* error) {
                              
                              //error handling
                              if (error!=nil) {
                                  completionBlock(error);
                                  return;
                              }
                              
                              //add the asset to the custom photo album
                              [self addAssetURL: assetURL toAlbum:albumName withCompletionBlock:completionBlock];
                
                          }];
}


//add the asset to the custom photo album, using ALAssets library
-(void)addAssetURL:(NSURL*)assetURL toAlbum:(NSString*)albumName withCompletionBlock:(SaveImageCompletion)completionBlock
{
    
    
    //if(self.albumController!=nil) {
    //    [self.albumController addPhotoWithAssetURLToAlbum:assetURL. albumName:albumName];
    //}
    
    /**
     
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
     
     */
    
    __block BOOL albumWasFound = NO;
    
    //search all photo albums in the library
    [library enumerateGroupsWithTypes:ALAssetsGroupAlbum
                           usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                               
                               //compare the names of the albums
                               if ([albumName compare: [group valueForProperty:ALAssetsGroupPropertyName]]==NSOrderedSame) {
                                   
                                   //target album is found
                                   albumWasFound = YES;
                                  
                                   
                                   //get a hold of the photo's asset instance
                                   [library assetForURL: assetURL
                                            resultBlock:^(ALAsset *asset) {
                                                
                                                //add photo to the target album
                                                [group addAsset: asset];
                                                
                                                //run the completion block
                                                completionBlock(nil);
                                                
                                            } failureBlock: completionBlock];
                                   
                                   //album was found, bail out of the method
                                   
                                       
                                                                          
                                   return;
                               }
                               
                               if (group==nil && albumWasFound==NO) {
                                   //photo albums are over, target album does not exist, thus create it
                                   
                                   __weak ALAssetsLibrary* weakSelf = library;
                                   
                                   //create new assets album
                                   [library addAssetsGroupAlbumWithName:albumName
                                                            resultBlock:^(ALAssetsGroup *group) {
                                                                
                                                                //get the photo's instance
                                                                [weakSelf assetForURL: assetURL
                                                                          resultBlock:^(ALAsset *asset) {
                                                                              
                                                                              //add photo to the newly created album
                                                                              [group addAsset: asset];
                                                                              
                                                                              //call the completion block
                                                                              completionBlock(nil);
                                                                              
                                                                          } failureBlock: completionBlock];
                                                                
                                                            } failureBlock: completionBlock];
                                   
                                   //should be the last iteration anyway, but just in case
                                   return;
                               }
                               
                           } failureBlock: completionBlock];
    
}

-(void) saveImageMetadata {
    // Get the image metadata (EXIF & TIFF)
    NSMutableDictionary * imageMetadata = [[imageInfo objectForKey:UIImagePickerControllerMediaMetadata] mutableCopy];
    
    if(imageMetadata==nil){
        //NSLog(@"this one is nil");
        imageMetadata = [[NSMutableDictionary alloc]init];
    }
    // add GPS data
    // need a location here
    NSLog(@"saving location %@",photoLocation);
    if ( photoLocation!=nil ) {
        NSDictionary *locationInfo = [self getGPSDictionaryForLocation:photoLocation];
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
}

#pragma location dictionary
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
