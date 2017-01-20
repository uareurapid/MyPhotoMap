//
//  SearchLocationViewController.m
//  CollectionViewTutorial
//
//  Created by Paulo Cristo on 6/11/13.
//  Copyright (c) 2013 Bryan Hansen. All rights reserved.
//

#import "SearchLocationViewController.h"
#import "PhotoDetailViewController.h"
#import "PCAppDelegate.h"
#import "PhotosMapViewController.h"

@interface SearchLocationViewController ()

@end

@implementation SearchLocationViewController

@synthesize searchBar,placesList, placesTableView;
@synthesize assetURL,image, selectedAlbum,thumbnailURL;
@synthesize locationEntitiesArray;
@synthesize mapView;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        placesList = [[NSMutableArray  alloc] init];
        self.searchDisplayController.searchBar.delegate = self;
        self.placesTableView.delegate = self;
        [self.searchDisplayController setActive:true];
        self.searchBar.delegate = self;
        self.title = @"Edit location";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.mapView = ((PCAppDelegate *)[[UIApplication sharedApplication] delegate]).mapViewController;
    //load existing data on database
    [self fetchLocationRecords];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"viewWillAppear--> Asset url is %@",assetURL);
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//These are the delegate methods for the text field of the search placeholder
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    //text changed
    NSLog(@"searching for %@",searchText);
}


- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    UITextField *searchField = [self.searchBar valueForKey:@"_searchField"];
    searchField.placeholder = @"";
    [placesList removeAllObjects];
    [placesTableView reloadData];
    NSLog(@"clear suff");
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
    //searchBar.hidden = YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
  
    [self.searchBar resignFirstResponder];
    UITextField *searchField = [self.searchBar valueForKey:@"_searchField"];
    [self requestGeocodeLocation:searchField.text];
    
}



- (void) requestGeocodeLocation:(NSString *)address
{
    
    NSString *url = [NSString stringWithFormat:@"http://maps.google.com/maps/api/geocode/json?address=%@&sensor=false",address];
    url=[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
        //Formulate the string as a URL object.
    NSURL *requestURL=[NSURL URLWithString:url];
    
    NSLog(@"Requesting %@",requestURL);
    NSData* data = [NSData dataWithContentsOfURL: requestURL];
    
    
    // convert to JSON
    NSError *myError = nil;
    NSDictionary *res = [NSJSONSerialization JSONObjectWithData: data options:NSJSONReadingMutableLeaves error:&myError];
    
    NSMutableArray *placemarks;
    
    // show all values
    for(id key in res) {
        
        id value = [res objectForKey:key];
        
        NSString *keyAsString = (NSString *)key;
        //NSString *valueAsString = (NSString *)value;
        
        if([keyAsString isEqualToString:@"results"])
        {
            NSArray * components = (NSArray *) value;
             NSLog(@"number of results in geocode requests is %lu",(unsigned long)components.count);
            
            placemarks = [[NSMutableArray alloc] initWithCapacity:components.count];
            
            
            for(id elem in components)
            {
                
                MyGPSPosition *place  =[[MyGPSPosition alloc ] init];

                
                NSDictionary * component = (NSDictionary *) elem;
                for(id innerKey in component)
                {
                    keyAsString = (NSString *)innerKey;
                    if([keyAsString isEqualToString:GOOGLE_KEY_DATA_FORMATED_ADDRESS])
                    {
                        NSString *formatedAddress = [component objectForKey:innerKey];
                        NSLog(@"The formatedAddress is %@", formatedAddress);
                        place.location = formatedAddress;
                    }
                    else if([keyAsString isEqualToString:GOOGLE_KEY_DATA_GEOMETRY])
                    {
                        NSDictionary *location = [component objectForKey:innerKey];
                        NSLog(@"The location object is %@", location);
                        
                        
                        NSDictionary *locationCoords = [location objectForKey:PARAMETER_LOCATION];
                        
                        NSNumber *lat = [locationCoords objectForKey:PARAMETER_LATITUDE];
                        NSNumber *lg = [locationCoords objectForKey:PARAMETER_LONGITUDE];
                        
                        //need to convert them to NSSTring
                        place.longitude = [NSString stringWithFormat:@"%@",lg];
                        place.latitude = [NSString stringWithFormat:@"%@",lat];
                        
                        CLLocation *locationCL = [[CLLocation alloc] initWithLatitude:[place.latitude doubleValue]
                                                              longitude:[place.longitude doubleValue]];
                        
                        place.clLocation = locationCL;
                        
                        
                        
                    }
                    
                }
                
                //add to the list
                if(![placemarks containsObject:place]) {
                    [placemarks addObject:place];
                }
                
            }
            
        }
    }
    
    
    [self displayPlacemarks:placemarks];
    
    
    
}

// display the results, this is already called into another separate thread
- (void)displayPlacemarks:(NSMutableArray *)placemarks 
{
    
    int size = placemarks.count;
    
    if(size>0) {
        
        //we´re adding strings here
        //if(searchType==SEARCH_MODE_GEOLOCATION) {
        [placesList addObjectsFromArray:placemarks];//only add to this list
        
        dispatch_async(dispatch_get_main_queue(),^ {
            
            
            //begin update of table, insert the geocoded locations
            [self.placesTableView beginUpdates];
            
            int section = 0 ;
            
            for(int i=0; i < size; i++)
            {
                
                NSArray *insertIndexPaths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:i inSection:section]];
                [self.placesTableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationNone];
                
            }
            
            [self.placesTableView endUpdates];
            
        });
        
    }
    
    
}

//for the table view
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"places list count is: %lu",(unsigned long)placesList.count);
    return placesList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;//using ARC otherwise would have to call autorelease at the end
    }
    //just play safe here
    if(indexPath.row < placesList.count) {
        MyGPSPosition *item = (MyGPSPosition *)[placesList objectAtIndex:indexPath.row];
        cell.textLabel.text = item.location;
    }
    
	cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	
    return cell;
}

//user clicked the location row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    MyGPSPosition *placemark = [placesList objectAtIndex:indexPath.row];
    
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self saveLocationRecord:placemark];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma save locations core data
//fetch all the records from the database
- (void)fetchLocationRecords {
    
    //add a clause
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(lastName like %@) AND (birthday > %@)", lastNameSearchString, birthdaySearchDate];
    //and then use: NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    
    
    NSMutableArray *mutableFetchResults = [CoreDataUtils fetchLocationRecordsFromDatabase];
    if (!mutableFetchResults) {
        // Handle the error.
        // This is a serious error and should advise the user to restart the application
        return;
    }
    /*else {
        for(LocationDataModel *entity in mutableFetchResults) {
            //load the thumbnail
            if(entity.assetURL!=nil) {
              [self loadAssetInfoFromDataModel:entity];
            }
        }
    }*/
 
    // Save our fetched data to an array
    [self setLocationEntitiesArray: mutableFetchResults];

    //if(image!=nil && OK==YES) {
    //NSLog(@"Adding to the map....");
    //[mapView addLocation:location.clLocation withImage:image andTitle:@"Another teste"];
}

//save the location record
-(void)saveLocationRecord:(MyGPSPosition*)location {
    
    LocationDataModel *locationObject = nil;
    //FIRST check if already exists the model on database
    NSMutableArray *records = [CoreDataUtils fetchLocationRecordsFromDatabaseWithAssetURL:[assetURL absoluteString]];
    if(records==nil || (records!=nil && records.count > 1 )) {
        //OOPS, something is very wrong
        NSLog(@"something is very wrong");
        return;
    }
    
    NSManagedObjectContext *managedObjectContext = [(PCAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    BOOL isUpdate = false;
    
    if(records.count==1) {
        //already exists, just update it
        isUpdate = true;
        locationObject = [records objectAtIndex:0];
    }
    else {
        //does not exist yet, create one new
        locationObject = (LocationDataModel *)[NSEntityDescription insertNewObjectForEntityForName:@"LocationDataModel" inManagedObjectContext:managedObjectContext];
    }
    
    
    
   //current date
    //[locationObject setTimestamp: [NSDate date]];
    
    //I AM OVERWIRITING ALL THIS STUFF (WARN USER!!!!)
    [locationObject setName: [assetURL absoluteString]];
    locationObject.latitude = location.latitude;
    locationObject.longitude= location.longitude;
    
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
    locationObject.thumbnailURL = [thumbnailURL absoluteString];//need to save it as a string
    
    if(isAlbumType && [locationObject.assetURL isEqualToString: [selectedAlbum.assetURL absoluteString]] ) {
        //selectedAlbum
        if(selectedAlbum.photosCount > 0) {
            for(NSURL *photoURL in selectedAlbum.photosURLs) {
                //update also the model for these photos
                //TODO add also annotations for individual photos or not???
                NSMutableArray *photoModels = [CoreDataUtils fetchLocationRecordsFromDatabaseWithAssetURL:[photoURL absoluteString]];
                if(photoModels!=nil && photoModels.count==1) {
                    LocationDataModel *model = [photoModels objectAtIndex:0];
                    model.latitude = locationObject.latitude;
                    model.longitude= locationObject.longitude;
                }
            }
        }
    }
    

   BOOL OK = YES;
   NSError *error;
   if(![managedObjectContext save:&error]){
       NSLog(@"Unable to save object error is: %@",error.description);
       OK= NO;
    //This is a serious error saying the record
    //could not be saved. Advise the user to
    //try again or restart the application.
   }

    //is a new one, add to the list
    if(!isUpdate) {
       [locationEntitiesArray insertObject:locationObject atIndex:0]; 
    }
    
    
    
    if(OK==YES) {
        NSLog(@"Adding location object to the map....");
        [self loadAssetInfoFromDataModel: locationObject isAlbum: isAlbumType];
    }
    
}




//will try to save the metadata, but of course it will not work
- (void) saveEXIF: (MyGPSPosition*)position {
    
    
    ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
    
    //NSMutableDictionary *metadata = [[NSMutableDictionary alloc] init];
    //[metadata setLocation:position.clLocation];
    
    
    //ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
    NSDictionary *gpsLocation = [self getGPSDictionaryForLocation:position.clLocation];
    
    
    //do the assets enumeration
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *asset){
        
        NSLog(@"INSIDE ENUMERATION ON search:");
        if(asset!=nil) {
            
            ALAssetRepresentation *rep = [asset defaultRepresentation];
            NSLog(@"image metadata is %@",rep.metadata);
            NSDictionary *metaInfo = rep.metadata;
            
            Byte *buffer = (Byte*)malloc(rep.size);
            NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:rep.size error:nil];
            NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];

            [asset setImageData:data metadata:metaInfo completionBlock:
            ^(NSURL *assetURL, NSError *error) {
                NSLog(@"got an error here %@",error);
            }];

        }
            
    
        
    };
    
    ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror){
        NSLog(@"Failed to get image, on search!");
        //failed to get image.
    };
    
    
    [assetslibrary assetForURL:assetURL resultBlock:resultblock failureBlock:failureblock];
    
    
    
    //(ALAssetsLibraryWriteImageCompletionBlock)completionBlock
    //[assetslibrary writeImageDataToSavedPhotosAlbum:gpsLocation:completionBlock:nil];
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

#pragma asset stuff
-(void) loadAssetInfoFromDataModel:(LocationDataModel*)model isAlbum: (bool) album {
    
    NSLog(@"Loading asset for model with assetURL %@: ",model.assetURL);
    
    if(model.assetURL!=nil && image == nil) {
        
        NSLog(@"TRYING TO LOAD IMAGE");
        //as usual. do the assets enumeration
        ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *asset){
            
            CGImageRef thumb = [asset thumbnail];
            
            
            if(thumb!=nil) {
                
                //TODO if it is of album type, it has no thumbnail (either select the first image or the default blank thumbnail)
                image = [UIImage imageWithCGImage:thumb];
                //alwyas update the UI in the main thread (ONLY WHEN WE HAVE THE THUMBNAIL)
                [self addLocationWithThumbnail:model];
            }
            else {
                //should never happen
                image = [UIImage imageNamed:@"concrete"];
                [self addLocationWithThumbnail:model];
            }
            
        };
        
        ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror){
            NSLog(@"Failed to get image for assetURL %@: ",model.assetURL);
            //failed to get image.
        };
        
        ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
        [assetslibrary assetForURL: [NSURL URLWithString: model.assetURL ] resultBlock:resultblock failureBlock:failureblock];
        
    }
    else {
        if(image == nil) {
            image = [UIImage imageNamed:@"concrete"];
        }
        [self addLocationWithThumbnail:model];
    }
    
    
    
    
}


-(void) addLocationWithThumbnail:(LocationDataModel *)model  {
    //always update the UI in the main thread (ONLY WHEN WE HAVE THE THUMBNAIL)
    dispatch_async(dispatch_get_main_queue(), ^{
        
        CLLocation *locationCL = [[CLLocation alloc] initWithLatitude:[model.latitude doubleValue]
                                                            longitude:[model.longitude doubleValue]];
        
        //if it is an album wer add all the other photos in it, to the annotation
        NSMutableArray *otherPhotos = nil;
        if([model.type isEqualToString: TYPE_ALBUM] && [model.assetURL isEqualToString: [selectedAlbum.assetURL absoluteString]] ) {
            //selectedAlbum
            if(selectedAlbum.photosCount > 0) {
                otherPhotos = [[NSMutableArray alloc] initWithCapacity:selectedAlbum.photosCount];
                [otherPhotos addObjectsFromArray:selectedAlbum.photosURLs];
            }
        }
        
        [mapView addLocation:locationCL withImage:image andTitle:model.desc forModel:model containingURLS:otherPhotos ];
        NSLog(@"Adding location to the map, read from database");
        
    });
}

@end
