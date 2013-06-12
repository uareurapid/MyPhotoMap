//
//  LocationEntity.h
//  CollectionViewTutorial
//
//  Created by Paulo Cristo on 6/12/13.
//  Copyright (c) 2013 Bryan Hansen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#define TYPE_ALBUM @"AL"
#define TYPE_PHOTO @"PH"

@interface LocationDataModel : NSManagedObject

@property (nonatomic, retain) NSString * latitude;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * longitude;
@property (nonatomic, retain) NSString * assetURL;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSDate * timestamp;

@end
