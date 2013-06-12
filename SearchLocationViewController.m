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
@synthesize assetURL,image;
@synthesize managedObjectContext,locationEntitiesArray;
@synthesize mapView;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        placesList = [[NSMutableArray  alloc] init];
        self.title = @"Edit location";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //Create ManagedObjectContext
    if (managedObjectContext == nil)
    {
        managedObjectContext = [(PCAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        //get a reference to map view too
        mapView = [(PCAppDelegate *)[[UIApplication sharedApplication] delegate] mapViewController];
    }
    
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
             NSLog(@"number of results in geocode requests is %d",components.count);
            
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
                        //NSLog(@"The formatedAddress is %@", formatedAddress);
                        place.location = formatedAddress;
                    }
                    else if([keyAsString isEqualToString:GOOGLE_KEY_DATA_GEOMETRY])
                    {
                        NSDictionary *location = [component objectForKey:innerKey];
                        //NSLog(@"The location object is %@", location);
                        
                        
                        NSDictionary *locationCoords = [location objectForKey:PARAMETER_LOCATION];
                        
                        NSNumber *lat = [locationCoords objectForKey:PARAMETER_LONGITUDE];
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
    
    // Define our table/entity to use
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"LocationDataModel" inManagedObjectContext:managedObjectContext];
    // Setup the fetch request
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    //this is equivalent to SELECT * FROM `LocationEntity` 
    
    
    // Define how we will sort the records
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"assetURL" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    //[sortDescriptor release];
    // Fetch the records and handle an error
    NSError *error;
    NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (!mutableFetchResults) {
        // Handle the error.
        // This is a serious error and should advise the user to restart the application
    }
    else {
        NSLog(@"Got %d results from database",mutableFetchResults.count);
        for(LocationDataModel *entity in mutableFetchResults) {
            NSLog(@"got result with assetURL: %@ and name: %@ and lg %@ and lat %@",entity.assetURL, entity.name, entity.longitude, entity.latitude);
            //load the thumbnail
            if(entity.assetURL!=nil) {
              [self loadAssetInfoFromDataModel:entity];
            }
        }
    }
 
    // Save our fetched data to an array
    [self setLocationEntitiesArray: mutableFetchResults];

    //if(image!=nil && OK==YES) {
    //NSLog(@"Adding to the map....");
    //[mapView addLocation:location.clLocation withImage:image andTitle:@"Another teste"];
}


//save the location record
-(void)saveLocationRecord:(MyGPSPosition*)location {
LocationDataModel *locationObject = (LocationDataModel *)[NSEntityDescription insertNewObjectForEntityForName:@"LocationDataModel" inManagedObjectContext:managedObjectContext];
   //current date
   [locationObject setTimestamp: [NSDate date]];
    [locationObject setName:@"teste"];
    locationObject.latitude = location.latitude;
    locationObject.longitude= location.longitude;
    
    if([[assetURL absoluteString] rangeOfString:@"group"].location==NSNotFound)
    {
      //it is an image
        locationObject.type = TYPE_PHOTO;
    }
    else {
        locationObject.type = TYPE_ALBUM;
    }
    
    locationObject.assetURL = [assetURL absoluteString];

   BOOL OK = YES;
   NSError *error;
   if(![managedObjectContext save:&error]){
       NSLog(@"Unable to save object error is: %@",error.description);
       OK= NO;
    //This is a serious error saying the record
    //could not be saved. Advise the user to
    //try again or restart the application.
   }

    [locationEntitiesArray insertObject:locationObject atIndex:0];
    if(image!=nil && OK==YES) {
        NSLog(@"Adding to the map....");
        [mapView addLocation:location.clLocation withImage:image andTitle:@"Another teste"];
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
-(void) loadAssetInfoFromDataModel:(LocationDataModel*)model {
    NSLog(@"Loading asset for model with assetURL %@: ",model.assetURL);
    //do the assets enumeration
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *asset){
        
        CGImageRef thumb = [asset thumbnail];
        
        
        //CLLocation *location = [asset valueForProperty:ALAssetPropertyLocation];
        //NSLog(@"asset location is %@",location);
        //NSLog(@"asset metadata is %@",rep.metadata);
        
        if(thumb!=nil) {
           
            __block UIImage *imageThumb = [UIImage imageWithCGImage:thumb];
            //image = imageThumb;
            NSLog(@"HERE 1");
            //alwyas update the UI in the main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                
                image = imageThumb;
                CLLocation *locationCL = [[CLLocation alloc] initWithLatitude:[model.latitude doubleValue]
                                                                    longitude:[model.longitude doubleValue]];
                [mapView addLocation:locationCL withImage:image andTitle:@"other test"];
                NSLog(@"HERE 2");
                
            });
        }
        
        
    };
    
    ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror){
        NSLog(@"Failed to get image!");
        //failed to get image.
    };
    
    ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
    [assetslibrary assetForURL: [NSURL URLWithString: model.assetURL ] resultBlock:resultblock failureBlock:failureblock];
}
@end
