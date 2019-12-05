//
//  CoreDataUtils.m
//  MyPhotoMap
//
//  Created by Paulo Cristo on 6/15/13.
//  Copyright (c) 2013 Paulo Cristo. All rights reserved.
//

#import "CoreDataUtils.h"


@implementation CoreDataUtils


+ (NSMutableArray *)fetchLocationRecordsFromDatabase {
    
    
    //NSMutableArray *locationEntitiesArray = [[NSMutableArray alloc] init];
    //add a clause
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(lastName like %@) AND (birthday > %@)", lastNameSearchString, birthdaySearchDate];
    //and then use: NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    
    
    NSManagedObjectContext *managedObjectContext = [(PCAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    
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
    
    /*
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
    }*/
    
    // Save our fetched data to an array
    return mutableFetchResults;
    
    //if(image!=nil && OK==YES) {
    //NSLog(@"Adding to the map....");
    //[mapView addLocation:location.clLocation withImage:image andTitle:@"Another teste"];
}

//get all with this description
+ (NSMutableArray *)fetchLocationRecordsFromDatabaseWithDescription: (NSString *) description {
    
    NSManagedObjectContext *managedObjectContext = [(PCAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    
    // Define our table/entity to use
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"LocationDataModel" inManagedObjectContext:managedObjectContext];
    // Setup the fetch request
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    //this is equivalent to SELECT * FROM `LocationEntity`
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(desc = %@)",description];
    
    [request setPredicate:predicate];
    
    // Define how we will sort the records
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"assetURL" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    //[sortDescriptor release];
    // Fetch the records and handle an error
    NSError *error;
    NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    
    
    return mutableFetchResults;
}

//get the one with this asset url
+ (NSMutableArray *)fetchLocationRecordsFromDatabaseWithAssetURL: (NSString *) assetURL {
    
    
    //dispatch_async(dispatch_get_main_queue(), ^{
    
    //})
    //TODO check warning delagate must be called from main thread only
    NSManagedObjectContext *managedObjectContext = [(PCAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    
    // Define our table/entity to use
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"LocationDataModel" inManagedObjectContext:managedObjectContext];
    // Setup the fetch request
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    //this is equivalent to SELECT * FROM `LocationEntity`
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(assetURL = %@)",assetURL];
    
    [request setPredicate:predicate];
    
    // Define how we will sort the records
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"assetURL" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    //[sortDescriptor release];
    // Fetch the records and handle an error
    NSError *error;
    NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    
    
    return mutableFetchResults;
}

+ (NSMutableArray *)fetchLocationRecordsFromDatabaseWithAssetURL: (NSString *) assetURL withManagedContext: (NSManagedObjectContext *) managedObjectContext{
    
    
    // Define our table/entity to use
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"LocationDataModel" inManagedObjectContext:managedObjectContext];
    // Setup the fetch request
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    //this is equivalent to SELECT * FROM `LocationEntity`
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(assetURL = %@)",assetURL];
    
    [request setPredicate:predicate];
    
    // Define how we will sort the records
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"assetURL" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    //[sortDescriptor release];
    // Fetch the records and handle an error
    NSError *error;
    NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    
    
    return mutableFetchResults;
}

#pragma SAVE LOCATION RECORD

+(LocationDataModel *)saveOrUpdateLocationRecord:(NSString*)assetURL withDate:(NSDate*) date andLocation:(CLLocation*) imageLocation andAssetType: (NSString *) type andDescription: (NSString *) description {
    
    
    NSManagedObjectContext *managedObjectContext = [(PCAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    BOOL __block OK = YES;
    NSError __block *error;
    
    NSMutableArray *results = [CoreDataUtils fetchLocationRecordsFromDatabaseWithAssetURL:assetURL];
    //check if a record with this assetURL already exists on DB
    if(results==nil || results.count == 0) {
        //we only add the ones that do not exist
        
        LocationDataModel *locationObject = (LocationDataModel *)[NSEntityDescription insertNewObjectForEntityForName:@"LocationDataModel" inManagedObjectContext:managedObjectContext];
        //current date
        if(date!=nil) {
            [locationObject setTimestamp: date];
        }
        else {
            [locationObject setTimestamp: [NSDate date]];
        }
        
        //TODO THE NAME SAME OF ASSET? WHY??? THERE IS A PROPER FIELD
        [locationObject setName: assetURL];
        [locationObject setDesc:description];//TODO pass this to the annotation title
        
        
        bool isAlbumType = false;
        
        if([type isEqualToString:TYPE_PHOTO])
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
        
        locationObject.assetURL = assetURL;
        locationObject.thumbnailURL = assetURL;//need to save it as a string
    
        
        if(imageLocation!=nil) {
            CLLocationCoordinate2D coordinate = imageLocation.coordinate;
            locationObject.latitude = [[NSString alloc] initWithFormat:@"%f", coordinate.latitude];
            locationObject.longitude= [[NSString alloc] initWithFormat:@"%f", coordinate.longitude];
        }
        else {
            locationObject.latitude = @"0000";
            locationObject.longitude= @"0000";
            
            
        }
        
        if(![managedObjectContext save:&error]){
            NSLog(@"Unable to save object error is: %@",error.description);
            OK= NO;
            //This is a serious error saying the record
            //could not be saved. Advise the user to
            //try again or restart the application.
        }
        
        if(OK==YES) {
            NSLog(@"saved model location: %@", locationObject.description);
            return locationObject;
        }
        
        
    } else if(results!=nil && results.count == 1) {
        //UPDATE
        NSLog(@"IT IS AN UPDATE, NOT INSERT");
        LocationDataModel *locationObject = [results firstObject];
        if(date!=nil) {
            [locationObject setTimestamp: date];
        }
        else {
            [locationObject setTimestamp: [NSDate date]];
        }

        if(description!=nil && locationObject.desc == nil) {
           [locationObject setDesc:description];//TODO pass this to the annotation title
        }
        
        locationObject.type = type;
        if(imageLocation!=nil) {
            CLLocationCoordinate2D coordinate = imageLocation.coordinate;
            locationObject.latitude = [[NSString alloc] initWithFormat:@"%f", coordinate.latitude];
            locationObject.longitude= [[NSString alloc] initWithFormat:@"%f", coordinate.longitude];
        }
        
        NSManagedObjectContext *managedObjectContext = [(PCAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        
        if(![managedObjectContext save:&error]){
            NSLog(@"Unable to update object error is: %@",error.description);
            OK= NO;
            //This is a serious error saying the record
            //could not be saved. Advise the user to
            //try again or restart the application.
        }
        
        if(OK==YES) {
            NSLog(@"Updated model %@ with location: %@", assetURL, locationObject.description);
            return locationObject;
        }
        
    }
    
    return nil;
    
    
}

@end
