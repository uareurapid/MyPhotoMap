//
//  CoreDataUtils.h
//  MyPhotoMap
//
//  Created by Paulo Cristo on 6/15/13.
//  Copyright (c) 2013 Paulo Cristo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocationDataModel.h"
#import "PCAppDelegate.h"

@interface CoreDataUtils : NSObject


+ (NSMutableArray *)fetchLocationRecordsFromDatabase;
+ (NSMutableArray *)fetchLocationRecordsFromDatabaseWithDescription: (NSString *) description;
+ (NSMutableArray *)fetchLocationRecordsFromDatabaseWithAssetURL: (NSString *) assetURL;
+(LocationDataModel *)saveOrUpdateLocationRecord:(NSString*)assetURL withDate:(NSDate*) date andLocation:(CLLocation*) imageLocation andAssetType: (NSString *) type andDescription: (NSString *) description;
@end
