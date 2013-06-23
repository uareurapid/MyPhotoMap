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

@end
